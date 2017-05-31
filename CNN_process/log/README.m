Here you can see part of the example running log for MV-CNN and RGB CNN.

I use K40 to run these codes.
Please run the following code before running fast_classification_UCF101_spatial.m and fast_classification_UCF101_temporal.m:
nvidia-smi -pm 1
nvidia-smi -ac 3004,875

The compuational time for temporal CNN (MV CNN) should around 0.16-0.17 sec.
The compuational time for spatial CNN (RGB CNN) should around 0.10 sec.

Since 250 optical flow and 25 rgb are processed, the speed should be 925 fps.
