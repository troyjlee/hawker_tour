function indices=makeRow(w)
w=w(:)';
indices=[];
n=size(w,2);

for i=1:n-1
  indices=[indices,tri2lin(w(i)*ones(1,n-i),w(i+1:n))];
endfor;
