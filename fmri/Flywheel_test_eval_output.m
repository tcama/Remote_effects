
% get file for analysis
cd('C:\Users\tca11\Desktop\CNT\Remote_effects\');
main_dir = './fmri/Adj_matrices/';
files = dir(main_dir);
files = files(3:end,:);
N = length(files);

% construct adjacency matrices
Adj = zeros(N,116,116);
for f = 1:N
    
    filepath = dir(fullfile(files(f).folder, files(f).name, 'aal116','*network.txt'));
    
    data = dlmread(fullfile(filepath.folder, filepath.name));
    A = zeros(116);
    n = 0;
    for i = 1:115
        for j = i+1:116
            n = n + 1;
            A(i,j) = data(n);
        end
    end
    A = A + A';
    Adj(f,:,:) = A;
end
idx = [1:70 79:90];
Adj = Adj(:,idx,idx);

% get average connectivity and module parcellations
Adj_avg = squeeze(mean(Adj));
[Ci,Q]=modularity_und(Adj_avg);
[X,Y,indsort] = grid_communities(Ci);

% plot each subject individually with group level parcellation
n = 0;
figure
for i = 1:N
        subplot(4,5,i)
        imagesc(squeeze(Adj(i,indsort,indsort)));
        hold on
        plot(X,Y,'r','linewidth',2);
        caxis([-1 1])
        title(['Subject ',num2str(i)])
        xlabel('AAL regions');
        ylabel('AAL regions');
end

% plot group level connectivity and parcellation
subplot(4,5,19)
imagesc(squeeze(Adj_avg(indsort,indsort)));
        hold on
        plot(X,Y,'r','linewidth',2);
        title('Average connectivity');
        xlabel('AAL regions');
        ylabel('AAL regions');
        caxis([-1 1])
        subplot(4,5,20)
        colorbar
        caxis([-1 1])
        axis off
        
% assess correlations between subjects
R = zeros(N);
for i = 1:N-1
    for j = i+1:N
        [r,p] = corrcoef(Adj(i,:,:),Adj(j,:,:));
        R(i,j) = r(2);
        P(i,j) = p(2);
    end
end
R = R + R';
figure
imagesc(R)
colorbar


