switchfigure.m()

fig = figure();   %record that handle!
ax = subplot(1, 2, 1, 'Parent', fig);   %tell it *which* figure you are drawing in
ph = plot(ax, rand(1,10));  %tell it which axes to draw on
hold(ax, 'on');             %tell it which axes to hold
set(ph, 'Marker', '*')      %be specific about what handle you are affecting
xlabel(ax, 'x Label 121');  %tell it which axes to affect
set(ph, 'XData', 5:50, 'YData', cos(5:50));  %update an existing handle for efficiency!