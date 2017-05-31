%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% setting GPU & Enviroment etc.
addpath('caffe/matlab');
caffe.reset_all();
caffe.set_mode_gpu();
gpu_id = 0;
caffe.set_device(gpu_id);

pp = 0;

[foldername, videoname, filename, labelid] = textread('lst/UCF-101_testSplit1_25frames.lst','%s %s %d %d');

net_model = ['prototxt/temporal_cls.prototxt'];
net_weights = ['models/temporal_UCF101_list01.caffemodel'];
if ~exist(net_weights, 'file')
  error('Please download Model before you run this demo');
end

net = caffe.Net(net_model, net_weights, 'test');
scores_total=zeros(101,size(foldername,1)/25);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Processing videos
for i=1:25:size(filename)
    ii=1;
    t_io = 0;
    t1 = clock;
    for j=0:24
	im_data_index = 1;
	for k=filename(i+j):filename(i+j)+10-1
	  i_str=sprintf('%04d',k);

      t2 = clock;
	  im_x = caffe.io.load_image(['ucf101_flow_img_mvs/',char(foldername{i+j}),'/',videoname{i+j},'/flow_x_',i_str,'.jpg']);
	  im_y = caffe.io.load_image(['ucf101_flow_img_mvs/',char(foldername{i+j}),'/',videoname{i+j},'/flow_y_',i_str,'.jpg']);
      t3 = clock;
      t_io= etime(t3,t2)+t_io;
  
	  im_data_ori(:,:,im_data_index,j+1) = im_x(60:60+223,16:16+223);
	  im_data_ori(:,:,im_data_index + 1,j+1) = im_y(60:60+223,16:16+223);
	  im_data_index = im_data_index + 2;
	end
    end
	input_data = bsxfun(@minus,im_data_ori,128);

    net.blobs('data').set_data(input_data);
    net.forward_prefilled();
    scores= net.blobs('prob').get_data();
    scores_total(:,(i-1)/25+1) = mean(scores, 2);
    t4 = clock;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    total_time = etime(t4,t1);
    io_time = t_io;
    computation_time = total_time-t_io;
    fprintf(['Time (w/o I/O) of processing 250 optical frames: ',num2str(computation_time),'\n']);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%show results:
    [~, maxlabel] = max(mean(scores,2));
    maxlabel_total(:,(i-1)/25+1)=maxlabel;
    if (maxlabel==labelid(i)+1)
        pp=pp+1;
    end
    fprintf('%d/%d %d %d %f\n',pp,(i-1)/25+1,maxlabel, labelid(i)+1, pp/((i-1)/25+1));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Cleaning and etc.
save('UCF_temporal_list01.mat','scores_total');
caffe.reset_all();
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

