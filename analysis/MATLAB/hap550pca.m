% Compute prinicpal components (PCs) using a subset of samples from each
% study, and project the remaining samples onto the PCs.
clear

% Initialize the random number generator.
rng(1);

% LOAD GENOTYPE DATA.
fprintf('Loading genotype data.\n');
load('../../data/hap550.mat');
p = length(pos);

% Select a random subset of 1000 samples from each study.
fprintf('Selecting subset of samples.\n');
I = [];
for i = 1:3
  samples = find(study == i);
  I       = [I; samples(randperm(length(samples),1000))];
end
Xsub = X(I,:);

% Center the columns of the genotype matrix so that each column has a mean
% of zero.
fprintf('Centering columns of genotype matrix.\n');
mu = zeros(p,1);
for i = 1:p
  mu(i)     = mean(Xsub(:,i));
  X(:,i)    = X(:,i)    - mu(i);
  Xsub(:,i) = Xsub(:,i) - mu(i);
end

% Compute the first m PCs.
fprintf('Calculating first 10 principal components.\n');
Xsub    = double(Xsub);
[U S R] = svdk(Xsub,10);

% Get the eigenvalues; equivalently, the proportion of variance
% explained (PVE) by each PC up to a normalizing constant.
v = diag(S).^2;

% Project all the samples onto the PCs.
pc = X * R;
pc = double(pc);

% Create a new MAT file containing the PCA results.
fprintf('Saving PCA results to file.\n');
save('hap550_pc.mat','study','pc','v','-v7.3');

% Plot the samples projected onto the first two PCs. The first PC
% separates samples in Study 3 (blue) from studies 1 & 2 (orange & red).
figure(1)
set(gcf,'Color','white','PaperPositionMode','auto');
clf
colors = { 'darkorange'
           'firebrick'
           'royalblue' };
hold on
for i = 1:3
  samples = find(study == i);
  plot(pc(samples,1),pc(samples,2),'.','Color',rgb(colors{i}),...
       'MarkerSize',12);
end
hold off
set(gca,'FontSize',10,'FontName','fixed','TickDir','out');
xlabel('PC1');
ylabel('PC2');
