$ErrorActionPreference = 'Stop';
$ProgressPreference = 'SilentlyContinue';

if (!(Test-Path -Path minecraft)) {
  mkdir minecraft
}
cd minecraft

if (!(Test-Path -Path "$pwd\eula.txt")) {
  if ($Env:EULA -eq 'TRUE') {
    [System.IO.File]::WriteAllText("$pwd\eula.txt", "# Generated via Docker on $(Get-Date)`neula=TRUE")
  } else {
    echo ""
    echo "Please accept the Minecraft EULA at"
    echo "  https://account.mojang.com/documents/minecraft_eula"
    echo "by adding the following immediately after 'docker run':"
    echo "  -e EULA=TRUE"
    echo ""
    exit 1
  }
}

$SERVER_PROPERTIES="/data/server.properties"
$FTB_DIR="/data/FeedTheBeast"
$VERSIONS_JSON="https://launchermeta.mojang.com/mc/game/version_manifest.json"

# 2017-12-14 - Workaround for Azure Container Instances, where the network is not always immediately available for Windows Containers
$isNetworkAvailable = $false
while (!$isNetworkAvailable) {
  try {
    Invoke-WebRequest -Uri "https://launchermeta.mojang.com/mc/game/version_manifest.json"
    $isNetworkAvailable = $true
  } 
  catch {
    $date = Get-Date -Format g
    Write-Host "$data - Waiting on the network to become available"
    Start-Sleep -Seconds 1
  }
}

echo "Checking version information."
switch -regex ("X$Env:VERSION")
{
  "X|XLATEST|Xlatest" {
    $VANILLA_VERSION = (invoke-webrequest -Uri $VERSIONS_JSON | convertfrom-json | select -expand latest).release
    break
  }
  "XSNAPSHOT|Xsnapshot" {
    $VANILLA_VERSION = (invoke-webrequest -Uri $VERSIONS_JSON | convertfrom-json | select -expand latest).snapshot
    break
  }
  "X[1-9]*" {
    $VANILLA_VERSION = $Env:VERSION
    break
  }
  default {
    $VANILLA_VERSION = (invoke-webrequest -Uri $VERSIONS_JSON | convertfrom-json | select -expand latest).release
    break
  }
}

# function buildSpigotFromSource {
#   echo "Building Spigot $VANILLA_VERSION from source, might take a while, get some coffee"
#   mkdir /data/temp
#   cd /data/temp
#   wget -q -P /data/temp https://hub.spigotmc.org/jenkins/job/BuildTools/lastSuccessfulBuild/artifact/target/BuildTools.jar && \
#     java -jar /data/temp/BuildTools.jar --rev $VANILLA_VERSION 2>&1 |tee /data/spigot_build.log| while read l; do echo -n .; done; echo "done"
#   mv spigot-*.jar /data/spigot_server.jar
#   mv craftbukkit-*.jar /data/craftbukkit_server.jar
#   echo "Cleaning up"
#   rm -rf /data/temp
#   cd /data
# }

# function downloadSpigot {
#   local match
#   case "$TYPE" in
#     *BUKKIT|*bukkit)
#       match="Craftbukkit"
#       downloadUrl=${BUKKIT_DOWNLOAD_URL}
#       ;;
#     *)
#       match="Spigot"
#       downloadUrl=${SPIGOT_DOWNLOAD_URL}
#       ;;
#   esac

#   if [[ -z $downloadUrl ]]; then
#     downloadUrl=$(restify --class=jar-div https://mcadmin.net/ | \
#       jq --arg version "$match $VANILLA_VERSION" -r -f /usr/share/mcadmin.jq)
#     if [[ -z $downloadUrl ]]; then
#       echo "ERROR: Version $VANILLA_VERSION is not supported for $TYPE"
#       echo "       Refer to https://mcadmin.net/ for supported versions"
#       exit 2
#     fi
#   fi

#   echo "Downloading $match"
#   curl -kfsSL -o $SERVER "$downloadUrl"
#   status=$?
#   if [ ! -f $SERVER ]; then
#     echo "ERROR: failed to download from $downloadUrl (status=$status)"
#     exit 3
#   fi

# }

# function downloadPaper {
#   local build
#   case "$VERSION" in
#     latest|LATEST|1.10)
#       build="lastSuccessfulBuild";;
#     1.9.4)
#       build="773";;
#     1.9.2)
#       build="727";;
#     1.9)
#       build="612";;
#     1.8.8)
#       build="443";;
#     *)
#       build="nosupp";;
#   esac

#   if [ $build != "nosupp" ]; then
#     rm $SERVER
#     downloadUrl=${PAPER_DOWNLOAD_URL:-https://ci.destroystokyo.com/job/PaperSpigot/$build/artifact/paperclip.jar}
#     curl -fsSL -o $SERVER "$downloadUrl"
#     if [ ! -f $SERVER ]; then
#       echo "ERROR: failed to download from $downloadUrl (status=$?)"
#       exit 3
#     fi
#   else
#     echo "ERROR: Version $VERSION is not supported for $TYPE"
#     echo "       Refer to https://ci.destroystokyo.com/job/PaperSpigot/"
#     echo "       for supported versions"
#     exit 2
#   fi
# }

# function installForge {
#   TYPE=FORGE

#   if [[ -z $FORGE_INSTALLER && -z $FORGE_INSTALLER_URL ]]; then
#     norm=$VANILLA_VERSION

#     case $VANILLA_VERSION in
#       *.*.*)
#         norm=$VANILLA_VERSION ;;
#       *.*)
#         norm=${VANILLA_VERSION}.0 ;;
#     esac

#     echo "Checking Forge version information."
#     case $FORGEVERSION in
#       RECOMMENDED)
#         curl -fsSL -o /tmp/forge.json http://files.minecraftforge.net/maven/net/minecraftforge/forge/promotions_slim.json
#         FORGE_VERSION=$(cat /tmp/forge.json | jq -r ".promos[\"$VANILLA_VERSION-recommended\"]")
#         if [ $FORGE_VERSION = null ]; then
#           FORGE_VERSION=$(cat /tmp/forge.json | jq -r ".promos[\"$VANILLA_VERSION-latest\"]")
#           if [ $FORGE_VERSION = null ]; then
#             echo "ERROR: Version $VANILLA_VERSION is not supported by Forge"
#             echo "       Refer to http://files.minecraftforge.net/ for supported versions"
#             exit 2
#           fi
#         fi
#         ;;

#       *)
#         FORGE_VERSION=$FORGEVERSION
#         ;;
#     esac

#     normForgeVersion=$VANILLA_VERSION-$FORGE_VERSION-$norm
#     shortForgeVersion=$VANILLA_VERSION-$FORGE_VERSION

#     FORGE_INSTALLER="/tmp/forge-$shortForgeVersion-installer.jar"
#   elif [[ -z $FORGE_INSTALLER ]]; then
#     FORGE_INSTALLER="/tmp/forge-installer.jar"
#   elif [[ ! -e $FORGE_INSTALLER ]]; then
#     echo "ERROR: the given Forge installer doesn't exist : $FORGE_INSTALLER"
#     exit 2
#   fi

#   installMarker=".forge-installed-$shortForgeVersion"

#   if [ ! -e $installMarker ]; then
#     if [ ! -e $FORGE_INSTALLER ]; then

#       if [[ -z $FORGE_INSTALLER_URL ]]; then
#         echo "Downloading $normForgeVersion"

#         forgeFileNames="
#         $normForgeVersion/forge-$normForgeVersion-installer.jar
#         $shortForgeVersion/forge-$shortForgeVersion-installer.jar
#         END
#       "
#         for fn in $forgeFileNames; do
#           if [ $fn == END ]; then
#             echo "Unable to compute URL for $normForgeVersion"
#             exit 2
#           fi
#           downloadUrl=http://files.minecraftforge.net/maven/net/minecraftforge/forge/$fn
#           echo "...trying $downloadUrl"
#           if curl -o $FORGE_INSTALLER -fsSL $downloadUrl; then
#             break
#           fi
#         done
#       else
#         echo "Downloading $FORGE_INSTALLER_URL ..."
#         if ! curl -o $FORGE_INSTALLER -fsSL $FORGE_INSTALLER_URL; then
#           echo "Failed to download from given location $FORGE_INSTALLER_URL"
#           exit 2
#         fi
#       fi
#     fi

#     echo "Installing Forge $shortForgeVersion using $FORGE_INSTALLER"
#     mkdir -p mods
#     tries=3
#     while ((--tries >= 0)); do
#       java -jar $FORGE_INSTALLER --installServer
#       if [ $? == 0 ]; then
#         break
#       fi
#     done
#     if (($tries < 0)); then
#       echo "Forge failed to install after several tries." >&2
#       exit 10
#     fi

#     # NOTE $shortForgeVersion will be empty if installer location was given to us
#     echo "Finding installed server jar..."
#     for j in *forge*.jar; do
#       echo "...$j"
#       case $j in
#         *installer*)
#           ;;
#         *)
#           SERVER=$j
#           break
#           ;;
#       esac
#     done
#     if [[ -z $SERVER ]]; then
#       echo "Unable to derive server jar for Forge"
#       exit 2
#     fi

#     echo "Using server $SERVER"
#     echo $SERVER > $installMarker

#   else
#     SERVER=$(cat $installMarker)
#   fi
# }

# function isURL {
#   local value=$1

#   if [[ ${value:0:8} == "https://" || ${value:0:7} = "http://" ]]; then
#     return 0
#   else
#     return 1
#   fi
# }

# function installFTB {
#   TYPE=FEED-THE-BEAST

#   echo "Looking for Feed-The-Beast server modpack."
#   if [[ -z $FTB_SERVER_MOD ]]; then
#       echo "Environment variable FTB_SERVER_MOD not set."
#       echo "Set FTB_SERVER_MOD to the file name of the FTB server modpack."
#       echo "(And place the modpack in the /data directory.)"
#       exit 2
#   fi
#   local srv_modpack=${FTB_SERVER_MOD}
#   if isURL ${srv_modpack}; then
#       case $srv_modpack in
#         */download)
#           break;;
#         *)
#           srv_modpack=${srv_modpack}/download;;
#       esac
#       local file=$(basename $(dirname $srv_modpack))
#       local downloaded=/data/${file}.zip
#       echo "Downloading FTB modpack...
#   $srv_modpack -> $downloaded"
#       curl -sSL -o $downloaded $srv_modpack
#       srv_modpack=$downloaded
#   fi
#   if [[ ${srv_modpack:0:5} == "data/" ]]; then
#       # Prepend with "/"
#       srv_modpack=/${srv_modpack}
#   fi
#   if [[ ! ${srv_modpack:0:1} == "/" ]]; then
#       # If not an absolute path, assume file is in "/data"
#       srv_modpack=/data/${srv_modpack}
#   fi
#   if [[ ! -f ${srv_modpack} ]]; then
#       echo "FTB server modpack ${srv_modpack} not found."
#       exit 2
#   fi
#   if [[ ! ${srv_modpack: -4} == ".zip" ]]; then
#       echo "FTB server modpack ${srv_modpack} is not a zip archive."
#       echo "Please set FTB_SERVER_MOD to a file with a .zip extension."
#       exit 2
#   fi

#   echo "Unpacking FTB server modpack ${srv_modpack} ..."
#   mkdir -p ${FTB_DIR}
#   unzip -o ${srv_modpack} -d ${FTB_DIR}
#   cp -f /data/eula.txt ${FTB_DIR}/eula.txt
#   FTB_SERVER_START=${FTB_DIR}/ServerStart.sh
#   chmod a+x ${FTB_SERVER_START}
#   sed -i "s/-jar/-Dfml.queryResult=confirm -jar/" ${FTB_SERVER_START}
# }

function installVanilla {
  $global:SERVER="minecraft_server.$VANILLA_VERSION.jar"

  if (!(Test-Path -Path $SERVER)) {
    echo "Downloading $SERVER ..."
    Invoke-WebRequest -Uri (Invoke-WebRequest -Uri ((Invoke-WebRequest -Uri 'https://launchermeta.mojang.com/mc/game/version_manifest.json' | ConvertFrom-Json).versions | ? id -eq $VANILLA_VERSION).url | ConvertFrom-Json).downloads.server.url -OutFile "minecraft_server.$VANILLA_VERSION.jar"
  }
}

echo "Checking type information."
switch -regex ($Env:TYPE) {
  # *BUKKIT|*bukkit|SPIGOT|spigot)
  #   case "$TYPE" in
  #     *BUKKIT|*bukkit)
  #       SERVER=craftbukkit_server.jar
  #       ;;
  #     *)
  #       SERVER=spigot_server.jar
  #       ;;
  #   esac

  #   if [ ! -f $SERVER ]; then
  #      if [[ "$BUILD_SPIGOT_FROM_SOURCE" = TRUE || "$BUILD_SPIGOT_FROM_SOURCE" = true || "$BUILD_FROM_SOURCE" = TRUE || "$BUILD_FROM_SOURCE" = true ]]; then
  #        buildSpigotFromSource
  #      else
  #        downloadSpigot
  #      fi
  #   fi
  #   # normalize on Spigot for operations below
  #   TYPE=SPIGOT
  # ;;

  # PAPER|paper)
  #   SERVER=paper_server.jar
  #   if [ ! -f $SERVER ]; then
  #     downloadPaper
  #   fi
  #   # normalize on Spigot for operations below
  #   TYPE=SPIGOT
  # ;;

  # FORGE|forge)
  #   TYPE=FORGE
  #   installForge
  # ;;

  # FTB|ftb)
  #   TYPE=FEED-THE-BEAST
  #   installFTB
  # ;;

  "VANILLA|vanilla" {
    installVanilla
    break
  }

  default {
      echo "Invalid type: '$Env:TYPE'"
      echo "Must be: VANILLA, FORGE, SPIGOT"
      exit 1
  }
}


# # If supplied with a URL for a world, download it and unpack
# if [[ "$WORLD" ]]; then
# case "X$WORLD" in
#   X[Hh][Tt][Tt][Pp]*)
#     echo "Downloading world via HTTP"
#     echo "$WORLD"
#     wget -q -O - "$WORLD" > /data/world.zip
#     echo "Unzipping word"
#     unzip -q /data/world.zip
#     rm -f /data/world.zip
#     if [ ! -d /data/world ]; then
#       echo World directory not found
#       for i in /data/*/level.dat; do
#         if [ -f "$i" ]; then
#           d=`dirname "$i"`
#           echo Renaming world directory from $d
#           mv -f "$d" /data/world
#         fi
#       done
#     fi
#     if [ "$TYPE" = "SPIGOT" ]; then
#       # Reorganise if a Spigot server
#       echo "Moving End and Nether maps to Spigot location"
#       [ -d "/data/world/DIM1" ] && mv -f "/data/world/DIM1" "/data/world_the_end"
#       [ -d "/data/world/DIM-1" ] && mv -f "/data/world/DIM-1" "/data/world_nether"
#     fi
#     ;;
#   *)
#     echo "Invalid URL given for world: Must be HTTP or HTTPS and a ZIP file"
#     ;;
# esac
# fi

# # If supplied with a URL for a modpack (simple zip of jars), download it and unpack
# if [[ "$MODPACK" ]]; then
# case "X$MODPACK" in
#   X[Hh][Tt][Tt][Pp]*[Zz][iI][pP])
#     echo "Downloading mod/plugin pack via HTTP"
#     echo "  from $MODPACK ..."
#     curl -sSL -o /tmp/modpack.zip "$MODPACK"
#     if [ "$TYPE" = "SPIGOT" ]; then
#       if [ "$REMOVE_OLD_MODS" = "TRUE" ]; then
#         rm -rf /data/plugins/*
#       fi
#       mkdir -p /data/plugins
#       unzip -o -d /data/plugins /tmp/modpack.zip
#     else
#       if [ "$REMOVE_OLD_MODS" = "TRUE" ]; then
#         rm -rf /data/mods/*
#       fi
#       mkdir -p /data/mods
#       unzip -o -d /data/mods /tmp/modpack.zip
#     fi
#     rm -f /tmp/modpack.zip
#     ;;
#   *)
#     echo "Invalid URL given for modpack: Must be HTTP or HTTPS and a ZIP file"
#     ;;
# esac
# fi

# # If supplied with a URL for a config (simple zip of configurations), download it and unpack
# if [[ "$MODCONFIG" ]]; then
# case "X$MODCONFIG" in
#   X[Hh][Tt][Tt][Pp]*[Zz][iI][pP])
#     echo "Downloading mod/plugin configs via HTTP"
#     echo "  from $MODCONFIG ..."
#     curl -sSL -o /tmp/modconfig.zip "$MODCONFIG"
#     if [ "$TYPE" = "SPIGOT" ]; then
#       mkdir -p /data/plugins
#       unzip -o -d /data/plugins /tmp/modconfig.zip
#     else
#       mkdir -p /data/config
#       unzip -o -d /data/config /tmp/modconfig.zip
#     fi
#     rm -f /tmp/modconfig.zip
#     ;;
#   *)
#     echo "Invalid URL given for modconfig: Must be HTTP or HTTPS and a ZIP file"
#     ;;
# esac
# fi

function setServerProp($prop, $val) {
  if ($val) {
    echo "Setting $prop to $val"
    [System.IO.File]::WriteAllText("$pwd\server.properties", ((Get-Content -Raw .\server.properties) | % { $_ -Replace "$prop=(.*)`n", "$prop=$val`n" }))
  }
}

if (!(Test-Path -Path '.\server.properties')) {
  echo "Creating server.properties"
  cp C:\minecraft\server.properties .

#   if [ -n "$WHITELIST" ]; then
#     echo "Creating whitelist"
#     sed -i "/whitelist\s*=/ c whitelist=true" /data/server.properties
#     sed -i "/white-list\s*=/ c white-list=true" /data/server.properties
#   fi

  setServerProp "motd" $Env:MOTD
  setServerProp "allow-nether" $Env:ALLOW_NETHER
  setServerProp "announce-player-achievements" $Env:ANNOUNCE_PLAYER_ACHIEVEMENTS
  setServerProp "enable-command-block" $Env:ENABLE_COMMAND_BLOCK
  setServerProp "spawn-animals" $Env:SPAWN_ANIMALS
  setServerProp "spawn-monsters" $Env:SPAWN_MONSTERS
  setServerProp "spawn-npcs" $Env:SPAWN_NPCS
  setServerProp "generate-structures" $Env:GENERATE_STRUCTURES
  setServerProp "view-distance" $Env:VIEW_DISTANCE
  setServerProp "hardcore" $Env:HARDCORE
  setServerProp "max-build-height" $Env:MAX_BUILD_HEIGHT
  setServerProp "force-gamemode" $Env:FORCE_GAMEMODE
  setServerProp "hardmax-tick-timecore" $Env:MAX_TICK_TIME
  setServerProp "enable-query" $Env:ENABLE_QUERY
  setServerProp "query.port" $Env:QUERY_PORT
  setServerProp "enable-rcon" $Env:ENABLE_RCON
  setServerProp "rcon.password" $Env:RCON_PASSWORD
  setServerProp "rcon.port" $Env:RCON_PORT
  setServerProp "max-players" $Env:MAX_PLAYERS
  setServerProp "max-world-size" $Env:MAX_WORLD_SIZE
  setServerProp "level-name" $Env:LEVEL
  setServerProp "level-seed" $Env:SEED
  setServerProp "pvp" $Env:PVP
  setServerProp "generator-settings" $Env:GENERATOR_SETTINGS
  setServerProp "online-mode" $Env:ONLINE_MODE

#   if [ -n "$LEVEL_TYPE" ]; then
#     # normalize to uppercase
#     LEVEL_TYPE=$( echo ${LEVEL_TYPE} | tr '[:lower:]' '[:upper:]' )
#     echo "Setting level type to $LEVEL_TYPE"
#     # check for valid values and only then set
#     case $LEVEL_TYPE in
#       DEFAULT|FLAT|LARGEBIOMES|AMPLIFIED|CUSTOMIZED|BIOMESOP)
#         sed -i "/level-type\s*=/ c level-type=$LEVEL_TYPE" /data/server.properties
#         ;;
#       *)
#         echo "Invalid LEVEL_TYPE: $LEVEL_TYPE"
# 	exit 1
# 	;;
#     esac
#   fi

  if ($Env:DIFFICULTY) {
    switch -regex ($Env:DIFFICULTY) {
      "peaceful|0" {
        $Env:DIFFICULTY=0
        break
      }

      "easy|1" {
        $Env:DIFFICULTY=1
        break
      }

      "normal|2" {
        $Env:DIFFICULTY=2
        break
      }

      "hard|3" {
        $Env:DIFFICULTY=3
        break
      }
      
      default {
        echo "DIFFICULTY must be peaceful, easy, normal, or hard."
        exit 1
      }
    }

    setServerProp "difficulty" $Env:DIFFICULTY
  }

#   if [ -n "$MODE" ]; then
#     echo "Setting mode"
#     MODE_LC=$( echo $MODE | tr '[:upper:]' '[:lower:]' )
#     case $MODE_LC in
#       0|1|2|3)
#         ;;
#       su*)
#         MODE=0
#         ;;
#       c*)
#         MODE=1
#         ;;
#       a*)
#         MODE=2
#         ;;
#       sp*)
#         MODE=3
#         ;;
#       *)
#         echo "ERROR: Invalid game mode: $MODE"
#         exit 1
#         ;;
#     esac

#     sed -i "/^gamemode\s*=/ c gamemode=$MODE" $SERVER_PROPERTIES
#   fi
}


# if [ -n "$OPS" -a ! -e ops.txt.converted ]; then
#   echo "Setting ops"
#   echo $OPS | awk -v RS=, '{print}' >> ops.txt
# fi

# if [ -n "$WHITELIST" -a ! -e white-list.txt.converted ]; then
#   echo "Setting whitelist"
#   echo $WHITELIST | awk -v RS=, '{print}' >> white-list.txt
# fi

# if [ -n "$ICON" -a ! -e server-icon.png ]; then
#   echo "Using server icon from $ICON..."
#   # Not sure what it is yet...call it "img"
#   wget -q -O /tmp/icon.img $ICON
#   specs=$(identify /tmp/icon.img | awk '{print $2,$3}')
#   if [ "$specs" = "PNG 64x64" ]; then
#     mv /tmp/icon.img /data/server-icon.png
#   else
#     echo "Converting image to 64x64 PNG..."
#     convert /tmp/icon.img -resize 64x64! /data/server-icon.png
#   fi
# fi

# # Make sure files exist and are valid JSON (for pre-1.12 to 1.12 upgrades)
# for j in *.json; do
#   if [[ $(python -c "print open('$j').read().strip()==''") = True ]]; then
#     echo "Fixing JSON $j"
#     echo '[]' > $j
#   fi
# done

# # If any modules have been provided, copy them over
# mkdir -p /data/mods
# for m in /mods/*.{jar,zip}
# do
#   if [ -f "$m" -a ! -f "/data/mods/$m" ]; then
#     echo Copying mod `basename "$m"`
#     cp "$m" /data/mods
#   fi
# done
# [ -d /data/config ] || mkdir /data/config
# for c in /config/*
# do
#   if [ -f "$c" ]; then
#     echo Copying configuration `basename "$c"`
#     cp -rf "$c" /data/config
#   fi
# done

# if [ "$TYPE" = "SPIGOT" ]; then
#   if [ -d /plugins ]; then
#     echo Copying any Bukkit plugins over
#     cp -r /plugins /data
#   fi
# fi

$EXTRA_ARGS=""
# Optional disable console
if ($Env:CONSOLE -eq 'false' -or $Env:CONSOLE -eq 'FALSE') {
  $EXTRA_ARGS+="--noconsole"
}

# Workaround - Server without nogui blows up in Windows containers
$EXTRA_ARGS="$EXTRA_ARGS nogui"

# put these prior JVM_OPTS at the end to give any memory settings there higher precedence
$INIT_MEMORY = if ($Env:INIT_MEMORY -ne $null) { $Env:INIT_MEMORY } else { $Env:MEMORY }
$MAX_MEMORY = if ($Env:MAX_MEMORY -ne $null) { $Env:MAX_MEMORY } else { $Env:MEMORY }
echo "Setting initial memory to $INIT_MEMORY and max to $MAX_MEMORY"
$JVM_OPTS="-Xms$INIT_MEMORY -Xmx$MAX_MEMORY ${JVM_OPTS} -d64"

# Workaround - the version of log4j used by Minecraft blows up on code page 65001, and you can't change it on Nano Server
$ENCODING_HACK = "-Dsun.stdout.encoding=UTF-8"

if ($Env:TYPE -eq "FEED-THE-BEAST") {
    # cp -f $SERVER_PROPERTIES ${FTB_DIR}/server.properties
    # cp -f /data/{eula,ops,white-list}.txt ${FTB_DIR}/
    # cd ${FTB_DIR}
    # echo "Running FTB server modpack start ..."
    # exec sh ${FTB_SERVER_START}
}
else
{
    $JAVA_ARGS = @($Env:JVM_XX_OPTS, $JVM_OPTS, $ENCODING_HACK, "-jar", $SERVER, "$@", $EXTRA_ARGS) | ? {$_}

    # If we have a bootstrap.txt file... feed that in to the server stdin
    if (Test-Path -Path '/data/bootstrap.txt') 
    {
        # java $Env:JVM_XX_OPTS $JVM_OPTS -jar $SERVER "$@" $EXTRA_ARGS < /data/bootstrap.txt
    } 
    else
    {
        start-process -FilePath java -ArgumentList $JAVA_ARGS -wait -PassThru -NoNewWindow | out-null
    }
}