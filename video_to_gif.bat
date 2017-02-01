@echo off

                        rem    'start' is how many seconds into the video to wait before starting to record the GIF
                        rem    Set it to zero if you want to start at the beginning of the video

                        rem    'length' sets how long the GIF will record. 
                        rem    If start is set to 4 and length set to 5 the GIF will record seconds 4 through 9 of the video
set start=0
set length=10

                        rem    keeps the current directory from changing if a file is dropped in the file explorer from a different folder
cd /d "%~dp0" 

                        rem    If the spot for the video file name isn't blank then it jumps to the make_gif section
if not [%1] == [] goto make_gif

                        rem    If a video file name wasn't given at the command line the message below is echoed and then the program quits
echo Please provide a video file name. Additionally you can include the time in seconds from the video that the GIF starts on and the GIF's length in seconds.
goto:eof


:make_gif

  set "gif_folder=GIFs"
  if not exist %gif_folder% mkdir %gif_folder%
  
                        rem    this splits the file name from the file extension and then uses the name for the GIF
  for %%f in (%1) do ( set "gif_name=%%~nf" )
  set gif_file="%gif_folder%\%gif_name%.gif"
  
                        rem    Assigns default values at the start of the file if none given at command line
  if [%2] == [] ( 
    set start_time=%start%
  ) else (
    set start_time=%2
  )
                       
  if [%3] == [] (
    set duration=%length%
  ) else (
    set duration=%3
  )

  echo Creating GIF, please wait.
  
                        rem    GIF making information adapted from http://blog.pkh.me/p/21-high-quality-gif-with-ffmpeg.html
  
  set palette="%gif_folder%\palette.png"
  set filters="fps=15,scale=480:-2:flags=lanczos"
  
                        rem    the first run generates a global palette of 256 colors that will be used for every frame
                        
			                  rem    the stats_mode option can be either stats_mode=diff or stats_mode=full
                        rem    stats_mode=full chooses colors that will optimize colors for the entire frame 
                        rem    while stats_mode=diff optimizes colors to make the changes look good 
  start /b /wait ffmpeg.exe -v error -i %1 -ss %start_time% -t %duration% -vf "%filters%,palettegen=stats_mode=diff" -y %palette%
  
                        rem    the second run uses the color palette while making the GIF
  start /b /wait ffmpeg.exe -v error -i %1 -ss %start_time% -t %duration% -i %palette% -lavfi "%filters% [x]; [x][1:v] paletteuse" -y %gif_file%

  rm %palette%
