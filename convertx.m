function X=convertx(x)
X=zeros(18,18);
j=1;
for i=1:17
  X(i,(i+1):18)=x(j:(j+18-i-1))';
  j=j+18-i;
endfor;
