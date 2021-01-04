function plotCoordinateFrame(T, cs, k)
%PLOTCOORDINATEFRAME Plot a coordinate frame origin and orientation
%   Coordinate frames have a origin and an orientation. This function draws
%   the coordinate axes in a common frame.

    % T_WA  (t,R) describe the frame w.r.t the world (i.e., plot)

    % cs    Color spec of frame (filled sphere at origin)
    % k     Size of each axis

    if nargin < 3, k = 1; end
    if nargin < 2, cs = 'k'; end
    R = T(1:3,1:3);
    t = T(1:3,4);

    % Create coordinate axes starting at 0
    kk = linspace(0,k,100);
    CX = [kk; zeros(1,length(kk)); zeros(1,length(kk))];
    CY = [zeros(1,length(kk)); kk; zeros(1,length(kk))];
    CZ = [zeros(1,length(kk)); zeros(1,length(kk)); kk];
    
    % First rotate the coordinate frame from the local frame to the
    % orientation of the desired frame in which we want to plot.
    CX = R*CX;
    CY = R*CY;
    CZ = R*CZ;
    
    % Then translate this frame to its origin
    CX = repmat(t, 1, size(CX,2)) + CX;
    CY = repmat(t, 1, size(CY,2)) + CY;
    CZ = repmat(t, 1, size(CZ,2)) + CZ;
    
    % Plot the axes
    hold on; ls = '-';
    plot3(CX(1,:), CX(2,:), CX(3,:),'color','r','linewidth',2,'linestyle',ls);
    plot3(CY(1,:), CY(2,:), CY(3,:),'color','g','linewidth',2,'linestyle',ls);
    plot3(CZ(1,:), CZ(2,:), CZ(3,:),'color','b','linewidth',2,'linestyle',ls);
    scatter3(t(1), t(2), t(3), cs, 'filled');
end