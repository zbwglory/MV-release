%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% setting GPU & Enviroment etc.
addpath('caffe/matlab');
caffe.reset_all();

caffe.set_mode_gpu();
gpu_id = 1;
caffe.set_device(gpu_id);
pp=0;

[foldername, videoname, filename, labelid] = textread('lst/UCF-101_testSplit1_25frames.lst','%s %s %d %d');

net_model = ['prototxt/spatial_cls.prototxt'];
net_weights = ['models/spatial_UCF101_list01.caffemodel'];
phase = 'test';
if ~exist(net_weights, 'file')
  error('Please download CaffeNet from Model Zoo before you run this demo');
end

net = caffe.Net(net_model, net_weights, phase);
im_data_ori = zeros(340,256, 3,25,'single');
mean_data = caffe.io.read_mean('mean/VGG_mean.binaryproto');

input_data = zeros(224,224,3,25);
scores_total=zeros(101,size(foldername,1)/25);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Processing videos
for i=1:25:size(filename)
    ii=1;
    t_io = 0;
    t1 = clock;
    for j=0:24
	for k=filename(i+j):filename(i+j)
	  i_str=sprintf('%04d',k);
      t2 = clock;
      im = caffe.io.load_image(['ucf101_image/',char(foldername{i+j}),'/',char(videoname{i+j}),'/flow_i_',i_str,'.jpg']);
      t3 = clock;
      t_io = etime(t3,t2) + t_io;

	  im_data_ori(:,:,:,j+1) = im(:,:,:);
%      im_data_mirror(:,:,:,j+1) = im(end:-1:1,:,:);
	end
    end

	input_data = im_data_ori(60:60+223,16:16+223,:,:);
	input_data = bsxfun(@minus,input_data,mean_data);

    net.blobs('data').set_data(input_data);
    net.forward_prefilled();
    scores = net.blobs('prob').get_data();
    scores_total(:,(i-1)/25+1) = mean(scores, 2);
    t4 = clock;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    total_time = etime(t4,t1);
    io_time = t_io;
    computational_time = etime(t4,t1)-t_io;
    fprintf(['Time (w/o I/O) of processing 25 rgb frames: ',num2str(computational_time),'\n'])

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%show results:
    [~, maxlabel] = max(mean(scores,2));
    if (maxlabel==labelid(i)+1)
        pp=pp+1;
    end
    fprintf('%d/%d %d %d %f\n',pp,(i-1)/25+1,maxlabel, labelid(i)+1, pp/((i-1)/25+1));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Cleaning and etc.
save('UCF101_spatial_list01.mat','scores_total');
caffe.reset_all();
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
