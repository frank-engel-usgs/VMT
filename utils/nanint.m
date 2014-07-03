data=u1;
datais=isnan(data);
cc=size(data);
aa=cc(1);
bb=cc(2);
for nn=1:aa;
for mm=2:bb-1;
if datais(nn,mm)==1;
data(nn,mm)=(data(nn,mm-1)+data(nn,mm+1))/2;
end
end
end
u1=data;
clear data datais cc aa bb nn mm

data=v1;
datais=isnan(data);
cc=size(data);
aa=cc(1);
bb=cc(2);
for nn=1:aa;
for mm=2:bb-1;
if datais(nn,mm)==1;
data(nn,mm)=(data(nn,mm-1)+data(nn,mm+1))/2;
end
end
end
v1=data;
clear data datais cc aa bb nn mm

data=w1;
datais=isnan(data);
cc=size(data);
aa=cc(1);
bb=cc(2);
for nn=1:aa;
for mm=2:bb-1;
if datais(nn,mm)==1;
data(nn,mm)=(data(nn,mm-1)+data(nn,mm+1))/2;
end
end
end
w1=data;
clear data datais cc aa bb nn mm
disp('done nanint')