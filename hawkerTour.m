% This program solves TSP for a set of 18 hawker centres in Singapore
% by starting with a basic linear programming relaxation and adding 
% additional constraints valid for tours

% The labeling of hawker centres used is
% 1: ABC brickhouse
% 2: Amoy St
% 3: Changi
% 4: Chinatown
% 5: Chomp Chomp
% 6: East Coast Lagoon
% 7: Geylang Serai
% 8: Ghim Moh
% 9: Golden Mile Complex
% 10: Hong Lim
% 11: Lau Pa Sat
% 12: Maxwell Rd
% 13: Newton
% 14: Old Airport Rd
% 15: Tampines Round Market
% 16: Tekka Centre
% 17: Tiong Bahru
% 18: Whampoa

% The distance matrix is given in the file cost.m

cost;

% This loads an 18x18 matrix C where the (i,j) entry is distance, in meters,
% from hawker i to hawker j.  
% Distances were taken from driving distance on google maps and are not 
% symmetric.  First we symmetrize.

C=(C+C')/2;

% From the symmetric distance matrix we create a vector c of 
% length 18*17/2=153 holding the distances.

c=[];
for i=1:17 
  c=[c,C(i,i+1:18)];
endfor

% Convert to column vector
c=c(:);

% Now we create the constraints Ax=b.  The first 18 constraints say that 
% sum_{i \ne j} x_{ij}=2
% ctype holds the type of inequality---these are equalities so we use "S"
A=[];
b=[];

for i=1:18
  indices1=tri2lin(i*ones(1,18-i),i+1:18);  
  indices2=tri2lin(1:i-1,i*ones(1,i-1));
  A(i,[indices1,indices2])=1;
  b(i)=2;
  ctype(i)="S";
endfor

% These basic constraints do not give a true tour.
% We add degree constraints on edges (1,8), (3,15), (2,11) that their 
% weight is at most 1.  As these are upper bounds ctype takes "U"


A(19,tri2lin(1,8))=1;
A(20,tri2lin(3,15))=1;
A(21,tri2lin(2,11))=1;
b(19:21)=1;
ctype(19:21)="U";

% Now we start adding subtour constraints to eliminate small cycles

% Add subtour constraint for vertices 3,6,15
w=[3,6,15];
indices=makeRow(w);
A(22,indices)=1;
b(22)=2;
ctype(22)="U";

% Add subtour constraint for 1,8,17
w=[1,8,17];
indices=makeRow(w);
A(23,indices)=1;
b(23)=2;
ctype(23)="U";

% Add subtour constraint for 2,11,12
w=[2,11,12];
indices=makeRow(w);
A(24,indices)=1;
b(24)=2;
ctype(24)="U";


% Add a subtour constraint for the vertices 1,2,4,8,10,11,12,17
w=[1,2,4,8,10,11,12,17];
indices=makeRow(w);
A(25,indices)=1;
b(25)=7;
ctype(25)="U";

% Add a subtour constraint for the vertices 1,2,4,8,10,11,12,13,16,17
w=[1,2,4,8,10,11,12,13,16,17];
indices=makeRow(w);
A(26,indices)=1;
b(26)=9;
ctype(26)="U";

% glpk also takes an argument for upper bound and lower bound on variables
% we won't use these, so we just set them to empty

lb=[];
ub=[];

% Run the LP solver glpk

% To see the result using only a subset of the constraints you can run
% for example
% [x,val]=glpk(c,A(1:24,:),b(1:24),lb,ub,ctype(1:24));

[x,val]=glpk(c,A,b,lb,ub,ctype);

% Finally, we put the solution into a form that is easier to read
% X backs the compressed vector x back into a matrix

X=convertx(x);

% From the matrix it is still inconvenient to reconstruct the tour
% the variable edges contains the indices of the edges we have nonzero 
% weight in the solution and the corresponding weight
% With this is easy to reconstruct the tour

[a,b,v]=find(X);

% We display the edges as a matrix with three columns 
% each row is of the form [i j weight] where weight is the weight of the 
% edge between i and j

edges=sortrows([a,b,v],1)
