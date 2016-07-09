tar xvf ffmpeg-2.7.2.tar
mkdir v_ApplyEyeMakeup_g01_c01
ffmpeg-2.7.2/doc/examples/extract_mvs v_ApplyEyeMakeup_g01_c01.avi > dump.mvs0; MV-code-release/Release/mpegflow -f dump.mvs0 -x v_ApplyEyeMakeup_g01_c01/flow_x -y v_ApplyEyeMakeup_g01_c01/flow_y -b 20

