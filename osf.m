function w=osf(X,Y)
% Function selecting a linear combination of the data to increase the
% energy of X and decrease that of Y. This is in fact optimal spatial
% filter.
% INPUT
% X: data during the  activity of the system (LxN, where L is the number of
% features and N the number of patterns)
% Y: data during the rest of the system
% OUTPUT
% w: projection vector -> Xnew=wX, Ynew=wY, so that the energy of Xnew is
% larger than that of Ynew.

% Whitening of the data
Rxx=X*X';Ryy=Y*Y';
% regularization
lambda_xx=abs(max(eig(Rxx)))*1e-15;lambda_yy=abs(max(eig(Ryy)))*1e-15;
Rxx=Rxx+lambda_xx*eye(size(Rxx));
Ryy=Ryy+lambda_yy*eye(size(Ryy));
SS=Rxx^0.5;SS=real(SS);
% solution of the eigenvalue problem
M=SS*(Ryy\SS);M=(M+M')/2;[V,D]=eig(M);
% selection of the optimal solution
[~,I]=sort(diag(D));w=V(:,I(end));
w=SS\w;w=w/norm(w);
end