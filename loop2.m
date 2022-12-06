function loop2(jj, st, fin2, stf, finf, high, low, gsfact, dgs, cycles, dcy, days, dd, lrate, dlr, cells, l2, igpu, rout)

% jj = 0
% st = 460
% fin2 = 517
% stf = 10
% finf = 10
% low = .04
% high = 1
% gsfact1 = 0.9
% dgs = 0.2
% dcy = 50
% dd = 20
% dlr = 0
% l2 = 0
% 
% cycles_st = 1100
% cycles_fin = 900
% cycles_delta = -50
% days_st = 1
% days_fin = 150
% days_delta = 1
% cells_st = 350
% cells_fin = 240
% cells_delta = -30
% lrate_st = 8
% lrate_fin = 5
% lrate_delta = -1
% gsfact_st = 7
% gsfact_fin = 8
% gsfact_delta = 1


% aiload v1
% 8/13/22 4 inputsba_10min1
%  


% aiload v1
% 8/13/22 4 inputs
%
%l2=.0029;
%st=460;
%fin2=517;
%stf=8;
%finf=8;

forw=0;
 %rout='C:\Users\sfous\Desktop\forex\2year\rtest8aaz.csv';
low=.001;
high=1;
rng('default');  % initilize the net work ???????????????
%delete(gcp('nocreate'))
gpuDevice(igpu)
b1=gpuDevice(igpu);
reset(b1);
rng('default');
% parpool('local',igpu)
m2=zeros(1,12);


fname="C:\Users\sfous\Desktop\forex\2year\for1.xls";  % change back to for1
rtfname="C:\Users\sfous\Desktop\forex\2year\testba.xlsx"; % day oanda data
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

tic;
%for cycles=260:10:750
%    cycles=260;
%    for days=330:30:330 %330
%       for cells=450:15:450  %450 for 8
%        for lrate1=7:1:7
%            lrate=lrate1*.001;
%            for gsfact1=9:-2:9
%                gsfact=.1*gsfact1;
                for afile=stf:finf
                    win=0;
                    lose=0;
                    gtotal=0;
                    %
                    % make ai input file here here
                    %
                    ain=zeros(height(t),5); %4*length(names));
                    for i=2:height(t)
                        %load 4 inputs for each market
                        k1=0;
                        for j=afile:1:afile %length(names)
                            ain(i,k1+1)=snfai(i,8,j);    % sn8
                            ain(i,k1+2)=snfai(i,16,j);   % sn16
                            ain(i,k1+3)=snfai(i,4,j);    % close price
                            ain(i,k1+4)=snfai(i,1,j);    % med term diff
                            ain(i,k1+5)=snfai(i,2,j);    % short term diff
                            %     ain(i,k1+6)=snfai(i,5,j);  % high price day
                            %  ain(i,k1+7)=snfai(i,6,j);    % low for afile 11
                            %       ain(i,k1+6)=snfai(i,1,j)-snfai(i-1,1,j);  % slopw of mwd
                            % ain(i,k1+6)=snfai(i,7,j);    % rsi
                            %  ain(i,k1+6)=snfai(i,17,j);    %   long term
                            k1=k1+5;
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
                    [rows inputSize]=size(ain);
                    muX=zeros(inputSize);
                    SigmaX=zeros(inputSize);
                    for j=1:inputSize
                        muX(j) = mean(ain(:,j));
                        sigmaX(j) = std(ain(:,j));
                    end
                    for i=1:length(ain)
                        for j=1:inputSize
                            ain(i,j)= (ain(i,j)-muX(j))./ sigmaX(j);  %%%%%%%
                            %     TTrain{n} = (TTrain{n} - muT) ./ sigmaT;
                        end
                    end
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


                    for k=st:fin2 % length(sn)-1


                        layers = [
                            sequenceInputLayer(5)
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
                            Shuffle='never',...
                            ExecutionEnvironment='gpu', ...
                           L2Regularization=l2,...
                           LearnRateDropFactor=0.4, ...
                            SquaredGradientDecayFactor=gsfact, ...
                            InitialLearnRate=lrate, ....
                            Verbose=false, ...
                            ValidationData={bin(:,k+1),bout(k+1)}, ...
                            ValidationFrequency=50);% ...
                        %     Plots="training-progress");

                        %    L2Regularization=0.014,...
                        tain=bin(:,1:k);
                        taout=bout(:,1:k);    %   ( k-days)          k-days
                        %clear net1;
                       reset(b1);
rng('default');
                        net1 = trainNetwork(bin(:,k-days:k),bout(k-days:k),layers,options);
                        % test results here
                        a=bin(:,k-days:k+1);             % k-days
                        %temp= predict(net1,bin(:,k+1));  % results for resinx wihich is i
                        tempc=classify(net1,bin(:,k+1));
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
    fmt='%3.0f file=%2.0f win=%2.0f lose=%2.0f  %2.3f %3.3f %1.0f %4.0f days%3.0f lrate%0.3f cell%3.0f l %0.3f h %0.3f igpu %3.0f \n';
    fprintf(fmt,k,afile,win,lose,100*(win-lose)/(win+lose),toc/60,3,cycles,days,lrate,cells,low,high,igpu);

                    end % st fin2 days
                end % stf finf  files
           % end % gsfact
        %end % lrate1
       %end %cells
   % end % days
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
    fmt='%3.0f file=%2.0f win=%2.0f lose=%2.0f  %2.3f %3.3f %1.0f %4.0f days%3.0f lrate%0.3f cell%3.0f l %0.3f h %0.3f \n';
    fprintf(fmt,i,afile,win,lose,100*(win-lose)/(win+lose),toc,look,cycles,days,lrate,cells,low,high);
   toc
    m2(1,1)=cycles;
    m2(1,2)=afile;
    m2(1,3)=win;
    m2(1,4)=lose;
    m2(1,5)=(win-lose)/(win+lose);
    m2(1,6)=days;
    m2(1,7)=lrate;
    m2(1,8)=cells;
    m2(1,9)=low;
    m2(1,10)=gsfact;
    m2(1,11)=igpu;
    m2(1,12)=230;  % 2 for shuffle and 1 for default or 0 ,3 is for clear net and shuffle
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


