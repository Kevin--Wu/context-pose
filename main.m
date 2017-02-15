function [] = main()
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% setting the dataset
% Using the subset 3:
% Horizontal Wave(HoW)
% Hammer(H)
% Forward Punch(FP)
% High Throw(HT)
% Hand Clap(HC)
% Bend(B)
% Tennis Serve(TSr)
% Pickup Throw(PT)
% the corresponding label is 
% 2 3 5 6 10 13 18 20
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
total_action_num=20;
action_subset3=[2,3,5,6,10,13,18,20];
test_kind=3;
train_subject=[];
test_subject=[];
if(test_kind==3)
    %test_kind=3,using the cross subject test
    train_subject=[1,3,5,7,9];
    test_subject=[2,4,6,8,10];
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%get the train and test data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[train_data,train_action_num,train_action_lines]=get_data(action_subset3,train_subject);
[test_data,test_action_num,test_action_lines]=get_data(action_subset3,test_subject);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%get each action's start line number
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
train_actstart_num=[1];
test_actstart_num=[1];
for i=2:train_action_num
    train_actstart_num=[train_actstart_num,train_actstart_num(i-1)+train_action_lines(i-1)];
end
for i=2:test_action_num
    test_actstart_num=[test_actstart_num,test_actstart_num(i-1)+test_action_lines(i-1)];
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%setting the information of eigenjoint
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
frame_num=25;%ÿ������ȡ20��ͼƬ
dim_num=64;%ÿ��PCA�������ȡǰ32ά






%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%���濪ʼ��ȡtrain_Data��eigenjoint
%ע���test_data��eigenjoint������
%train_eigenjoint(i,j,k)��Ӧ��
%��i�ද���ĵ�j��eigenjoint��ע������û�ж������֮�֣�ֻ�ж������������
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%������ȡ˼·������ÿ��������������Ӧ��eigenjoint�������Ȼ��浽��Ӧ�ĵ�i�ද���Ķ�ά�ռ���

%�ȱ���һ��,�ҳ�ÿ�ද���ж�����
actionlines_in_traindata=zeros(1,20);

%ÿ��������ѡframe_num��ͼƬ�����ÿ�������ڶ�Ӧ������Ԫ���м�frame_num��
for i=1:train_action_num;
    actionlines_in_traindata(train_data(train_actstart_num(i),1))=actionlines_in_traindata(train_data(train_actstart_num(i),1))+frame_num;
end

train_eigenjoint=zeros(total_action_num,max(actionlines_in_traindata),dim_num);
temp_eigenjoint=zeros(frame_num,2970);
temp=zeros(frame_num*train_action_num,2971);%���һ���������涯�����
%��ʼ����train_eigenjoint
current_lines=ones(1,20);%�������������棬�ڹ���������ÿ�ද����ǰ������

for i=1:train_action_num
    start=train_actstart_num(i);
    
    for j=2:(frame_num+1)
        frame_start=start+20*(j-1);
        k=1;%1-2970
        
        %fcc
        for m=1:20
            for n=(m+1):20
                for column=1:3
                    %column+1����Ϊ��test_data��u��v��d�ֱ���2��3��4��
                    temp_eigenjoint(j-1,k)=train_data(frame_start+m-1,column+1)-train_data(frame_start+n-1,column+1);
                    k=k+1;
                end
                
            end
        end
        
        %fcp
        for m=1:20
            for n=1:20
                for column=1:3
                    temp_eigenjoint(j-1,k)=train_data(frame_start+m-1,column+1)-train_data(frame_start-20+n-1,column+1);
                    k=k+1;
                end
                
            end
        end
        
        %fci
        for m=1:20
            for n=1:20
                for column=1:3
                    temp_eigenjoint(j-1,k)=train_data(frame_start+m-1,column+1)-train_data(start+n-1,column+1);
                    k=k+1;
                end
                
            end
        end


        
    end
    
    min_num=min(min(temp_eigenjoint));
    max_num=max(max(temp_eigenjoint));
    
    for j=1:frame_num
        for k=1:2970
            %���Թ�һ��y = 2 * ( x - min ) / ( max - min ) - 1
            temp_eigenjoint(j,k)=2*(temp_eigenjoint(j,k)-min_num)/(max_num-min_num)-1;
        end
        
    end
    
    for j=1:frame_num
        for k=1:2970
            temp((i-1)*frame_num+j,k)=temp_eigenjoint(j,k);
        end
        temp((i-1)*frame_num+j,2971)=train_data(start,1);
    end
    
%     %�ڶ�action-i������frameȡ�����֮�󣬽���PCA��ά����
%     [pca,~,latent,~] = princomp(temp_eigenjoint);
%     temp=temp_eigenjoint*pca(:,1:dim_num);%�������ĵ�ʵ�鲿��˵����ȡǰ32ά
%     
%     action_type=train_data(start,1);%ȡ�øö���������һ����
%     
%     %�ѵõ���temp����train_eigenjoint��
%     for j=1:frame_num
%         train_eigenjoint(action_type,current_lines(action_type),:)=temp(j,:);
%         current_lines(action_type)=current_lines(action_type)+1;
%     end
end

[pca,~,latent,~]=princomp(temp(:,1:2970));

%�ѵõ���temp���飬������temp_eigenjoint����Ϊ�н飬����train_eigenjoint��
for i=1:train_action_num
    action_type=temp((i-1)*frame_num+1,2971);
    for j=1:frame_num
        for k=1:2970
            temp_eigenjoint(j,k)=temp((i-1)*frame_num+j,k);
        end
    end
    temp_eigenjoint=temp_eigenjoint*pca(:,1:dim_num);
    for j=1:frame_num
        train_eigenjoint(action_type,current_lines(action_type),:)=temp_eigenjoint(j,:);
        current_lines(action_type)=current_lines(action_type)+1;
    end
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%get the  eigenjoint fc in test data
%eigenjoint(i,j,k) corresponding to 
%action i frame j's eigenjoint
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
eigenjoint=zeros(test_action_num,frame_num,dim_num);%according to the paper,20 frames are enough?
temp_eigenjoint=zeros(frame_num,2970);
for i=1:test_action_num
    start=test_actstart_num(i);
    
    %abandon the initial frame,which is used to get fci
    for j=2:(frame_num+1)
        frame_start=start+20*(j-1);
        k=1;%1-2970
        
        %fcc
        for m=1:20
            for n=(m+1):20
                for column=1:3
                    %column+1����Ϊ��test_data��u��v��d�ֱ���2��3��4��
                    temp_eigenjoint(j-1,k)=test_data(frame_start+m-1,column+1)-test_data(frame_start+n-1,column+1);
                    k=k+1;
                end
                
            end
        end
        
        %fcp
        for m=1:20
            for n=1:20
                for column=1:3
                    temp_eigenjoint(j-1,k)=test_data(frame_start+m-1,column+1)-test_data(frame_start-20+n-1,column+1);
                    k=k+1;
                end
                
            end
        end
        
        %fci
        for m=1:20
            for n=1:20
                for column=1:3
                    temp_eigenjoint(j-1,k)=test_data(frame_start+m-1,column+1)-test_data(start+n-1,column+1);
                    k=k+1;
                end
                
            end
        end


        
        
        
        
    end

    min_num=min(min(temp_eigenjoint));
    max_num=max(max(temp_eigenjoint));
    
    for j=1:frame_num
        for k=1:2970
            %���Թ�һ��y = 2 * ( x - min ) / ( max - min ) - 1
            temp_eigenjoint(j,k)=2*(temp_eigenjoint(j,k)-min_num)/(max_num-min_num)-1;
        end
        
    end

    temp=temp_eigenjoint*pca(:,1:dim_num);%�������ĵ�ʵ�鲿��˵����ȡǰ32ά
    for ii=1:frame_num
        for jj=1:dim_num
            eigenjoint(i,ii,jj)=temp(ii,jj);
        end
    end
            
end

save('eigenjoint.mat','eigenjoint');





%��ʼ��NBNN����������
test_label=zeros(1,test_action_num);%��������ÿ��������label��


%����ÿ���������ֱ��������Ԥ��ֵ
for i=1:test_action_num
    arg_min=0;
    
    %�ֱ����ÿ����������еĸ�ͼƬ��d-NNC(d)֮��,˭��Сtest_label�͸�ֵ˭
    for j=1:size(action_subset3,2)
        
        %���ÿ��ͼƬ�����ڵ�j�������ڵĲ�
        temp_arg_min=0;
        for k=1:frame_num
            
            current_frame_eigenjoint=zeros(1,dim_num);%���汾ͼƬ��Ӧ��eigenjoint
            for ii=1:dim_num
                current_frame_eigenjoint(ii)=eigenjoint(i,k,ii);
            end
            
            nnc_dis=0;
            %�ҳ�ÿһ�У���Ӧһ��ͼƬ��eigenjoint����ѵ�����е�����ڣ�����ò�ֵ
            for ii=1:actionlines_in_traindata(action_subset3(j))
                
                temp_nnc_dis=0;
                for jj=1:dim_num
                    
                    %(d-nnc(d))^2
                    temp_nnc_dis=temp_nnc_dis+((current_frame_eigenjoint(jj)-train_eigenjoint(action_subset3(j),ii,jj)).^2);
                end
                
                if(nnc_dis==0)
                    nnc_dis=temp_nnc_dis;
                else
                    if(nnc_dis>temp_nnc_dis)
                        nnc_dis=temp_nnc_dis;
                    end
                end
                
            end
            
            temp_arg_min=temp_arg_min+nnc_dis;
        end
        
        if(arg_min==0)
            arg_min=temp_arg_min;
            test_label(i)=action_subset3(j);
        else
            if(arg_min>temp_arg_min)
                arg_min=temp_arg_min;
                test_label(i)=action_subset3(j);
            end
        end
    end
    
end

%��֤׼ȷ��
ac_num=0;
for i=1:test_action_num
    if(test_label(i)==test_data(test_actstart_num(i),1))
        ac_num=ac_num+1;
    end
end
accuracy=ac_num/test_action_num;

end













