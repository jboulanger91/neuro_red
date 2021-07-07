
function bincoorboundedline(mean_sample,sem_sample,title_name,color,xdist)

%For absolute distance
if xdist==0
    binsTemp=1:length(mean_sample);
    boundedline(binsTemp-0.5,mean_sample,sem_sample,color,'alpha','transparency',0.2); hold on;
    set(gca,'XTick',[0 2.5 5 7.5 10])
    set(gca,'XTickLabel',{'0','50','100','150','200'}); box off
    xlabel('Distance in um'); ylabel('% of significant correlations');
    set(findall(gca), 'LineWidth', 1.5); axis square
    axis([0,10,0,100])
    title(title_name)
    
    %For distances along the A/P axis
elseif xdist==1
    binsTemp=-length(mean_sample)/2+0.5:1:length(mean_sample)/2-0.5;
    boundedline(binsTemp,mean_sample,sem_sample,color,'alpha','transparency',0.2); hold on;
    set(gca,'XTick',[-10 -7.5 -5 -2.5 0 2.5 5 7.5 10])
    set(gca,'XTickLabel',{'-200','-150','-100','-50','0','50','100','150','200'}); box off
    xlabel('Distance in um, Left=Anterior'); ylabel('% of significant correlations');
    set(findall(gca), 'LineWidth', 1.5); axis square
    axis([-10,10,0,100])
    title(title_name)
end

end
