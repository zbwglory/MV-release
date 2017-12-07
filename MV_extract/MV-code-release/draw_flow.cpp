/*
 * draw_flow.cpp
 *
 *  Created on: Sep 23, 2015
 *      Author: bwzhang
 */


#include <opencv2/imgproc/imgproc.hpp>
#include <opencv2/highgui/highgui.hpp>
#include <opencv2/opencv.hpp>


//#include "internal.h"

#include <stdio.h>
#include <iostream>
#include <fstream>
using namespace cv;
using namespace std;



static void convertFlowToImage(const Mat &flow_x, const Mat &flow_y, Mat &img_x, Mat &img_y,
       double lowerBound, double higherBound) {
	#define CAST(v, L, H) ((v) > (H) ? 255 : (v) < (L) ? 0 : cvRound(255*((v) - (L))/((H)-(L))))
	for (int i = 0; i < flow_x.rows; ++i) {
		for (int j = 0; j < flow_y.cols; ++j) {
			float x = flow_x.at<float>(i,j);
			float y = flow_y.at<float>(i,j);
			img_x.at<uchar>(i,j) = CAST(x, lowerBound, higherBound);
			img_y.at<uchar>(i,j) = CAST(y, lowerBound, higherBound);
		}
	}
	#undef CAST
}

int main(int argc, char** argv){
	// IO operation
	const char* keys =
		{
			"{ f  | vidFile      | dump | filename of optical flow}"
			"{ x  | xFlowFile    | flow_x | filename of flow x component }"
			"{ y  | yFlowFile    | flow_y | filename of flow x component }"
			"{ b  | bound | 15 | specify the maximum of optical flow}"
		};

	CommandLineParser cmd(argc, argv, keys);
	string vidFile = cmd.get<string>("vidFile");
	string xFlowFile = cmd.get<string>("xFlowFile");
	string yFlowFile = cmd.get<string>("yFlowFile");
	string imgFile = cmd.get<string>("imgFile");
	int bound = cmd.get<int>("bound");

    int video_width = 320;
    int video_height = 240;

	int frame_num = 0;
	Mat image, prev_image, prev_grey, grey, frame;

	ifstream fin;
	cout << vidFile << endl;
	fin.open(vidFile.data());
	if (!fin) {
		cout << "error in opening file";
		return -1;
	}

	int frame_prev = 0;
	while(!fin.eof()) {
		// Output optical flow
		int mv_per_frame = -1;
		fin >> mv_per_frame;
		if (mv_per_frame == -1)
			break;
		int forback, blockx,blocky,srcx,srcy,dstx,dsty,minx,miny;
		Mat flow_x(video_height,video_width,CV_32F,Scalar(0));
		Mat flow_y(video_height,video_width,CV_32F,Scalar(0));
		for (int i=0; i<mv_per_frame; i++) {
			fin >> frame_num >> forback >> blockx >> blocky >> srcx >> srcy >> dstx >> dsty >> minx >> miny;
			for (int x=0; x<blockx; x++) {
				for (int y=0; y<blocky; y++) {
					if ((dstx-blockx/2+x < 0) || (dsty-blocky/2+y < 0) || (dstx-blockx/2+x > video_width-1) || (dsty-blocky/2+y > video_height-1) || (forback > 0))
						continue;
					flow_x.at<float>(dsty-blocky/2+y,dstx-blockx/2+x) = (float)minx;
					flow_y.at<float>(dsty-blocky/2+y,dstx-blockx/2+x) = (float)miny;
				}
			}
		}
		frame_num = frame_num-1;

		Mat imgX(flow_x.size(),CV_8UC1);
		Mat imgY(flow_y.size(),CV_8UC1);
		convertFlowToImage(flow_x,flow_y, imgX, imgY, -bound, bound);
		char tmp[20];
		sprintf(tmp,"_%04d.jpg",int(frame_num));

		Mat imgX_, imgY_, imgX_small, imgY_small;
		resize(imgX,imgX_, cv::Size(340,256));
		resize(imgY,imgY_, cv::Size(340,256));

		imwrite(xFlowFile + tmp,imgX_);
		imwrite(yFlowFile + tmp,imgY_);

		while (frame_prev < frame_num-1) {
			frame_prev ++ ;
			char tmp1[20];
			sprintf(tmp1,"_%04d.jpg",int(frame_prev));
			cout << tmp1 << endl;
			imwrite(xFlowFile + tmp1,imgX_);
			imwrite(yFlowFile + tmp1,imgY_);
		}
		frame_prev = frame_num;

	}
	return 0;
}
