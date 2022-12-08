function loop2(jj, st, fin2, stf, finf, high, low, gsfact, dgs, cycles, dcy, days, dd, lrate, dlr, cells, l2, igpu, hidx)


% aiload v1
% 8/13/22 4 inputs
%  
%l2=.00014;
%st=460;
%fin2=517;
%stf=6;
%finf=6;

forw=0;
% rout='C:\Users\User\Desktop\forex\2year\rtest6.csv';
%low=.001;
%high=1;
rng('default');  % initilize the net work ???????????????
%igpu=7
%delete(gcp('nocreate'))
gpuDevice(igpu)
b1=gpuDevice(igpu);
reset(b1);
% parpool('local',igpu)
m2=zeros(1,13);

fname="C:\Users\User\Desktop\forex\2year\for1.xls";  % change back to for1
rtfname="C:\Users\User\Desktop\forex\2year\testba.xlsx"; % day oanda data
rtnames=sheetnames(rtfname);
names=sheetnames(fname);
   for ifile=1:length(names)
        t = readtable(fname,'sheet',names(ifile,1),'PreserveVariableNames',true);
        t([1],:)=[];  % remove row 1 of headers in vp      
        sn=zeros(height(t),19);
  snfa1=zeros(height(t),19,length(names));
 snf21ai=zeros(height(t),3,length(names));
        rt= readtable(rtfname,'sheet',rtnames(ifile,1),'PreserveVariableNames',true,'Format','auto');   
        %
        %
        %
%         if long_short==0
%            fin=height(t)-1; 
%         end
      
        for i=1:height(t)
            sn(i,1)=t{i,2};
            sn(i,2)=t{i,22};

            % mid from vp
            sn(i,3)=rt{i,3};    %  open  rt3   t4
            sn(i,4)=rt{i,4};    %  close rt4   t5 
            sn(i,5)=rt{i,5};    %  high  rt5   t6
            sn(i,6)=rt{i,6};    %  low   rt6   t7
 
            sn(i,7)=t{i,8};
            sn(i,8)=t{i,9};
            sn(i,13)=t{i,14};
            sn(i,14)=t{i,15};
            sn(i,15)=t{i,16};
            sn(i,16)=t{i,17};
            sn(i,17)=t{i,18};
            sn(i,18)=t{i,19};
            sn(i,19)=(t{i,20});
            sn23(i,2)=(t{i,22});      % short term line 3 day
            sn(i,2)=(t{i,22});  % new short term diff 3 day ai average
        end         
         for ema=2:1:length(sn)
%            sn(ema,7)=sn(ema,14)-sn(ema-1,14); % slope of sn(:,18)
%            sn(ema,9)=sn(ema,17)-sn(ema-1,17);  % slope of sn emni sn17
%            sn(ema,13)=sn(ema,1)-sn(ema-1,1);   % mediam slope  in sn(i,1)
             sn(ema,8)=sn(ema,16)-sn(ema-1,16);  % slope of Ni index sn(:,16)
%            sn(ema,7)=sn(ema,2)-sn(ema-1,2);   % short term ai diff slope s2
         end
     %  sn(1,10)=0;
        sn(1,7)=0;
        sn(1,13)=0;
    %   sn(1,9)=0;
        sn(1,8)=0;
        snfai(:,:,ifile)=sn(:,:); % save in indexed file     
   end
   %
   %xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
   % start predictor here xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
   %xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
   %
   otc=1;
   cout=zeros(519,1,14);
   fin=length(sn)-3;
   ot=cell(14,10);
   cred=0;
   pred=0;
    resout1=zeros(fin,10,14);
   ggtotal=0;
% loops start here 
gsfact=.9;
dgs=.2;
cycles=100;
dcy=50;  % cyclest +50 5 steps
days=80;
dd=20;  % days 20,40,60,60,100
lrate=.006; 
dlr=.001; % 3 steps .003 .006 .009
tic;
%for cycles=450:50:550
    
%    for days=150:30:259
%       for cells=350:50:450
%        for lrate1=3:3:9
%            lrate=lrate1*.001;
%            for gsfact1=9:2:9
%                gsfact=.1*gsfact1;
                for afile=stf:finf
                    win=0;
                    lose=0;
                    gtotal=0;
                    %
                    % make ai input file here here
                    %
                    ain=zeros(height(t),4); %4*length(names));
                    for i=2:height(t)
                        %load 4 inputs for each market
                        k1=0;
                        for j=afile:1:afile %length(names)
                            ain(i,k1+1)=snfai(i,8,j);    % sn8
                            ain(i,k1+2)=snfai(i,16,j);   % sn16
                           % ain(i,k1+3)=snfai(i,4,j);    % close price
                            ain(i,k1+3)=snfai(i,1,j);    % med term diff
                            ain(i,k1+4)=snfai(i,2,j);    % short term diff
                            %     ain(i,k1+6)=snfai(i,5,j);  % high price day
                            %  ain(i,k1+7)=snfai(i,6,j);    % low for afile 11
                            %       ain(i,k1+6)=snfai(i,1,j)-snfai(i-1,1,j);  % slopw of mwd
                            % ain(i,k1+6)=snfai(i,7,j);    % rsi
                            %  ain(i,k1+6)=snfai(i,17,j);    %   long term
                            k1=k1+4;
                        end
                    end
                    %
                    % make output file for i to be the same day as i-1
                    %
                    aout=zeros(height(t),1);
                    clear cout;

                    for i=2:height(t)-1
                        aout(i+1,1)=snfai(i+1,4,afile);% tomarrows close price pit in i for taining
                        aout(i,1)=snfai(i,4,afile);
                        if aout(i,1)>aout(i+1,1)
                            cout(i,1)={'SHORT'};  % cout for classifcation
                        else
                            cout(i,1)={'LONG'};
                        end
                    end
                    cout(1,1)={'SHORT'};
                    cin=ain;
                    cout=cellstr(cout);
                    dout=categorical(cout);

                    ainc=ain;
                    %
                    % normilize data inputs
                    %
%                     [rows inputSize]=size(ain);
%                     muX=zeros(inputSize);
%                     SigmaX=zeros(inputSize);
%                     for j=1:inputSize
%                         muX(j) = mean(ain(:,j));
%                         sigmaX(j) = std(ain(:,j));
%                     end
%                     for i=1:length(ain)
%                         for j=1:inputSize
%                             ain(i,j)= (ain(i,j)-muX(j))./ sigmaX(j);  %%%%%%%
%                             %     TTrain{n} = (TTrain{n} - muT) ./ sigmaT;
%                         end
%                     end
                    %
                    % normilize data otputs
                    %
                    [outrows outputSize]=size(aout);
                    muXo=zeros(outputSize,1);
                    SigmaXo=zeros(outputSize,1);
                    for j=afile:afile
                        muXo = mean(aout(:,1));
                        sigmaXo = std(aout(:,1));
                    end
                    for i=1:length(aout)
                        aout(i,1)= (aout(i,1)-muXo)/ sigmaXo;
                    end
                    %
                    % make output file 1 output
                    %

                    %
                    % set test  days here
                    %

                    aint=ain(:,:); % input for i


                    bin=aint.';
                    bout=dout.';

ainall=ain;
                    for k=st:fin2 % length(sn)-1
% normilize data inputs for k-days to k+1

[rows inputSize]=size(ainall);
muX=zeros(inputSize);
SigmaX=zeros(inputSize);
for j=1:inputSize
    muX(j) = mean(ainall(k-days:k+1,j));
    sigmaX(j) = std(ainall(k-days:k+1,j));
end
for i=k-days:k+1
    for j=1:inputSize
        ain(i,j)= (ainall(i,j)-muX(j))./ sigmaX(j);  %%%%%%%
   %     TTrain{n} = (TTrain{n} - muT) ./ sigmaT;
    end
end
aint=ain(:,:); % input for i 
 bin=aint.';


%                  fmt='%3.0f %3.1f %3.1f \n';
%                  fprintf(fmt,k,toc/60,toc/3600);

                      layers = [
                            sequenceInputLayer(4)
                            bilstmLayer(cells)
                            fullyConnectedLayer(2)
                            softmaxLayer
                            classificationLayer];
                   

                        %
                        maxEpochs=cycles;
                        miniBatchSize=30; %2048; % pa
                        options = trainingOptions('rmsprop', ...
                            MaxEpochs=maxEpochs, ...
                            MiniBatchSize=miniBatchSize, ...
                            L2Regularization=0.00014,...
                            Shuffle='never',...
                            ExecutionEnvironment='gpu', ...
                            LearnRateDropFactor=0.4, ...
                            SquaredGradientDecayFactor=gsfact, ...
                            InitialLearnRate=lrate, ....
                            Verbose=true, ...
                            ValidationData={bin(:,k+1),bout(k+1)}, ...
                            ValidationFrequency=50);
                        % ...
                        %     Plots="training-progress");

                        %    L2Regularization=0.014,...
                        tain=bin(:,1:k);
                        taout=bout(:,1:k);    %   ( k-days)          k-days                     
reset(b1);
rng('default');
                        net1 = trainNetwork(bin(:,k-days:k),bout(k-days:k),layers,options);
                        % test results here
                        a=bin(:,k-days:k+1);             % k-days
                        %temp= predict(net1,bin(:,k+1));  % results for resinx wihich is i
                        tempc=classify(net1,bin(:,k+1));
                        %net1=resetState(net1);
                        if tempc=="SHORT";
                            resout1(k,1,afile)=2;
                        else
                            resout1(k,1,afile)=1;
                        end
                        close all;
                        % days+2 is the end of predicted day
                        resout1(k,3,afile)=snfai(k+1,4,afile); % close on input day with predition inputs
                        resout1(k,2,afile)=snfai(k+2,4,afile); % close actual at end of  precdted day
                        resout1(k,9,afile)=k+1;
                        resout1(k,10,afile)=k+2;
                        %  resout1(k,5,afile)=temp(1,1);    % thois one high for long
                        %  resout1(k,6,afile)=temp(2,1);  % This omne high for short

                        tinput=un(bin(3,k),muX(3),sigmaX(3));

                        pin=un(bin(3,k+1),muX(3),sigmaX(3));
                        po=un(bin(3,k+1),muX(3),sigmaX(3));
                        pout=po;
                        if k<length(sn)-1
                            ac=un(bin(3,k+2),muX(3),sigmaX(3));
                        else
                            ac=0;
                        end
                        win=0;
                        lose=0;
                        [win,lose,resout1]=tally(igpu,gsfact,m2,rout,fin2,snfai,afile,resout1,win,lose,st,k,cycles,days,lrate,cells,low,high);
    fmt='%3.0f file=%2.0f win=%2.0f lose=%2.0f  %2.3f %3.3f %1.0f %4.0f days%3.0f lrate%0.3f cell%3.0f l %0.3f h %0.3f igpu %2.0f progress %2.2f chunk_size %2.0f\n';
    fprintf(fmt,k,afile,win,lose,100*(win-lose)/(win+lose),toc,3,cycles,days,lrate,cells,low,high,igpu,progress,chunk_size);
   
                    end % st fin2 days
                end % stf finf  files
%            end % gsfact
%        end % lrate1
%       end %cells
%    end % days
%end % cycles

%
%  un normilize one number 
% a1 is the num 
% m1 is ther mean 
% s1 is std
% afile is the index for that coloum in orginal dat
%
function [a1]=un(a1,m1,s1,afile)
a1=a1*s1+m1;
end
%
%  
%
function [win,lose,resout1]=tally(igpu,gsfact,m2,rout,fin2,snfai,afile,resout1,win,lose,st,k,cycles,days,lrate,cells,low,high)
% long shortcounter


look=3; % 2 short 1 long 3 both
resout2(:,:)=resout1(:,:,afile);
for i=st:k

    if resout2(i,3)>resout2(i,2)
        resout2(i,4)=2;
    else
        resout2(i,4)=1;
    end
 
%     if resout2(i,6)>resout2(i,5)
%         resout2(i,4)=2;
%     else
%         resout2(i,4)=1;
%     end
    %short
    if look==2
    if resout2(i,1)~=0 &&resout2(i,4)~=0 && resout2(i,1)==2
        if resout2(i,1)==resout2(i,4) 
            win=win+1;
        else
            lose=lose+1;
        end
    end
end
%long
if look==1
    if resout2(i,1)~=0 && resout2(i,4)~=0 
        if resout2(i,1)==resout2(i,4) 
            win=win+1;
        else
            lose=lose+1;
        end
    end
end
%both
if look==3
   resout1(i,8,afile)=snfai(resout2(i,9),16,afile);
    if resout2(i,1)~=0 &&resout2(i,4)~=0  && abs(snfai(resout2(i,9),16,afile))>low 
        if resout2(i,1)==resout2(i,4)
            win=win+1;
        else
            lose=lose+1;
        end
    end

end
 
 
end
 
if i==fin2
    fmt='%3.0f file=%2.0f win=%2.0f lose=%2.0f  %2.3f %3.3f %1.0f %4.0f days%3.0f lrate%0.3f cell%3.0f l %0.3f h %0.3f igpu %2.0f table_idx %2.0f \n';
    fprintf(fmt,i,afile,win,lose,100*(win-lose)/(win+lose),toc,look,cycles,days,lrate,cells,low,high, igpu, hidx);
   
    m2(1,1)=cycles;
    m2(1,2)=afile;
    m2(1,3)=win;
    m2(1,4)=lose;
    m2(1,5)=100*(win-lose)/(win+lose);
    m2(1,6)=days;
    m2(1,7)=lrate;
    m2(1,8)=cells;
    m2(1,9)=low;
    m2(1,10)=gsfact;
    m2(1,11)=igpu;
    m2(1,12)=2304;
    
    if isfile(rout)      
        writematrix(m2,rout,'WriteMode','append');
    else
        writematrix(m2,rout)
    end
end
    resout1(1,5)=cycles;
        resout1(1,6)=days;
        resout1(1,7)=lrate;
        resout1(1,8)=cells;
        resout1(1,9)=low;     
  %  put id infor in resout1 i=1 5,6,7,8,9 and i=2 5,6,7,8,9
end

end


