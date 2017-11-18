This is the code for testing part of our CVPR code and further.

To run the code, you need to install ffmpeg and opencv 2.4.11.

We have attached a modified version of ffmpeg 2.7.2 on the code package.

To install ffmpeg and opencv. We follow the guide on http://www.ozbotz.org/opencv-installation/ . But you need to install ffmpeg of our version and opencv 2.4.11 instead.

**Note** This is a third-party website. We have no control of the content on this website. Please use the content carefully.

- For extracting Motion Vector image, you can run the extract_mvs_sample.sh. The code is designed for the videos with resolution of 340 * 256 (width * height). If you need to extract motion vector from different resolution, you can modified **line 56-57 of draw_flow.cpp from MV-code-release folder** to the desired resolution.


    **Note** The time reported in the paper is calculated without I/O, which means without the time of writing dump file and images to disk.

- The MV-code-release folder is created using eclipse.

The model of UCF-101 is released (both spatial part and motion vector part).
1. Motion vector model and Spatial Model for UCF-101 split1, split2, and split3 can be found on: https://drive.google.com/drive/folders/1RXXAauI_inR1KvO8ygQmeNBBKRbj3xDJ?usp=sharing

If you find any questions in this motion vector CNN code, please contact me: --1023zhangbowen@tongji.edu.cn-- Please use zbwglory@gmail.com instead.

Best regards,

Bowen


Please cite our paper in your publications if it helps your research:


    @inproceedings{ZhangWWQW16,
      author    = {Bowen Zhang and Limin Wang and Zhe Wang and Yu Qiao and Hanli Wang},
      title     = {Real-time Action Recognition with Enhanced Motion Vector CNNs},
      booktitle = {CVPR},
      year      = {2016},
      pages     = {2718-2726}
    }

This code is distributed under MIT LICENSE
