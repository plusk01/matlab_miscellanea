% Q.m
% Rotation representations based on quaternions
% Parker Lusk <parkerclusk@gmail.com>
% 1 April 2019

classdef Q
    %Q Quaternion class
    
    properties
        q % w,x,y,z vector of unit quaternion values
    end
    
    methods
        function obj = Q(varargin)
            if nargin == 0, obj.q = Q.Identity; end
            if nargin == 1, obj.q = varargin{1}; end
        end
        
        function R = toRotm(obj)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            w = obj.q(1);
            x = obj.q(2);
            y = obj.q(3);
            z = obj.q(4);

            Rxx = 1 - 2*(y^2 + z^2);
            Rxy = 2*(x*y - z*w);
            Rxz = 2*(x*z + y*w);

            Ryx = 2*(x*y + z*w);
            Ryy = 1 - 2*(x^2 + z^2);
            Ryz = 2*(y*z - x*w );

            Rzx = 2*(x*z - y*w );
            Rzy = 2*(y*z + x*w );
            Rzz = 1 - 2 *(x^2 + y^2);

            R = [ 
                Rxx,    Rxy,    Rxz;
                Ryx,    Ryy,    Ryz;
                Rzx,    Rzy,    Rzz];
        end
        
        function [u, theta] = toAxisAngle(obj)
            obj.q = obj.q/norm(obj.q);
            % https://www.euclideanspace.com/maths/geometry/rotations/conversions/quaternionToAngle/index.htm
            theta = 2*acos(obj.q(1));
            s = sqrt(1-obj.q(1)^2);
            if imag(s)
                disp(s)
            end
            if s < 0.001 % test to avoid divide by zero (s is always pos)
                u = [0;0;1];
            else
                u = obj.q(2:4)' ./ s;
            end
        end
        
        function eul = toRPY(obj)            
            % TODO: Replace with dependency-free implementation
            eul = quat2eul(obj.q,'XYZ');
        end
        
        function obj = normalized(obj)
            obj.q = obj.q/norm(obj.q);
        end
        
        function obj = mult(obj, q2)
            % extract quat components
            w1 = obj.q(1); x1 = obj.q(2); y1 = obj.q(3); z1 = obj.q(4);
            w2 = q2(1); x2 = q2(2); y2 = q2(3); z2 = q2(4);

            % quat: w, x, y, z
            obj.q = [w1*w2 - x1*x2 - y1*y2 - z1*z2;...
                     w1*x2 + x1*w2 - y1*z2 + z1*y2;...
                     w1*y2 + x1*z2 + y1*w2 - z1*x2;...
                     w1*z2 - x1*y2 + y1*x2 + z1*w2]';
        end
        
        function obj = cannonize(obj)
            w = obj.q(1);
            if w<0, obj.q = -obj.q; end
        end
        
        function v = Log(obj)
            % extract vector part (x, y, z)
            vec = obj.q(2:4);
            w = obj.q(1);

            % length of vector part
            norm_vec = norm(vec);

            if (norm_vec < 1e-8)
                v = zeros(3,1);
            else
                v = 2*atan2(norm_vec, w)*vec / norm_vec;
            end
        end
        
        function obj = slerp(obj, q2, alpha)
            q1 = quaternion(reshape(obj.q,1,4));
            q2 = quaternion(reshape(q2,1,4));
            qf = q1.slerp(q2,alpha);
            [w,x,y,z] = qf.parts();
            obj.q = [w x y z];
        end
        
    end
    methods(Static)
        function q = Identity()
            q = [1 0 0 0];
        end
        
        function obj = fromRotm(R)
            [r,c] = size( R );
            if( r ~= 3 || c ~= 3 )
                fprintf( 'R must be a 3x3 matrix\n\r' );
                return;
            end

            % [ Rxx, Rxy, Rxz ] = R(1,1:3); 
            % [ Ryx, Ryy, Ryz ] = R(2,1:3);
            % [ Rzx, Rzy, Rzz ] = R(3,1:3);

            Rxx = R(1,1); Rxy = R(1,2); Rxz = R(1,3);
            Ryx = R(2,1); Ryy = R(2,2); Ryz = R(2,3);
            Rzx = R(3,1); Rzy = R(3,2); Rzz = R(3,3);

            w = sqrt( trace( R ) + 1 ) / 2;

            % check if w is real. Otherwise, zero it.
            if( imag( w ) > 0 )
                 w = 0;
            end

            x = sqrt( 1 + Rxx - Ryy - Rzz ) / 2;
            y = sqrt( 1 + Ryy - Rxx - Rzz ) / 2;
            z = sqrt( 1 + Rzz - Ryy - Rxx ) / 2;

            [~, i] = max( [w,x,y,z] );

            if( i == 1 )
                x = ( Rzy - Ryz ) / (4*w);
                y = ( Rxz - Rzx ) / (4*w);
                z = ( Ryx - Rxy ) / (4*w);
            end

            if( i == 2 )
                w = ( Rzy - Ryz ) / (4*x);
                y = ( Rxy + Ryx ) / (4*x);
                z = ( Rzx + Rxz ) / (4*x);
            end

            if( i == 3 )
                w = ( Rxz - Rzx ) / (4*y);
                x = ( Rxy + Ryx ) / (4*y);
                z = ( Ryz + Rzy ) / (4*y);
            end

            if( i == 4 )
                w = ( Ryx - Rxy ) / (4*z);
                x = ( Rzx + Rxz ) / (4*z);
                y = ( Ryz + Rzy ) / (4*z);
            end
            
            obj = Q([ w x y z ]); 
        end
        
        function obj = fromRPY(R, P, Y)
            % elementary rotations (local-to-global)
            roll = [1 0 0; 0 cos(R) -sin(R); 0 sin(R) cos(R)];
            pitch = [cos(P) 0 sin(P); 0 1 0; -sin(P) 0 cos(P)];
            yaw = [cos(Y) -sin(Y) 0; sin(Y) cos(Y) 0; 0 0 1];

            % intrinsic Z-Y-X rotation (body w.r.t world)
            rotm = roll*pitch*yaw;
            
            obj = Q.fromRotm(rotm);
        end
        
        function obj = fromAxisAngle(u,theta)
            % make sure axis is normalized
            u = u/norm(u);
            ux = u(1); uy = u(2); uz = u(3);

            r11 = cos(theta) + ux*ux*(1-cos(theta));
            r12 = ux*uy*(1-cos(theta)) - uz*sin(theta);
            r13 = ux*uz*(1-cos(theta)) + uy*sin(theta);
            r21 = uy*ux*(1-cos(theta)) + uz*sin(theta);
            r22 = cos(theta) + uy*uy*(1-cos(theta));
            r23 = uy*uz*(1-cos(theta)) - ux*sin(theta);
            r31 = uz*ux*(1-cos(theta)) - uy*sin(theta);
            r32 = uz*uy*(1-cos(theta)) + ux*sin(theta);
            r33 = cos(theta) + uz*uz*(1-cos(theta));

            R = [r11 r12 r13; r21 r22 r23; r31 r32 r33];
            
            obj = Q.fromRotm(R);
        end
        
        function obj = fromTwoVectors(u,v)
            % from turbo math (ROSflight); Ogre3d source
            
            % ensure vectors are normalized
            u = reshape(u/norm(u), 3, 1);
            v = reshape(v/norm(v), 3, 1);
            
            % cosine distance between the two vectors
            d = dot(u,v);
            
            % If the vectors are the same, return identity quat
            if (d == 1), obj = Q; return; end
            
            invs = 1/sqrt(2*(1+d));
            xyz = cross(u,v)*invs;
            w = 0.5/invs;
            obj = Q([w xyz']);
            
        end
        
        function v = boxminus(q1, q2)
            dq = Q(Q.inv(q1)).mult(q2).cannonize().q;
            v = Q(dq).Log();
        end
        
        function qinv = inv(q)
            qinv = q;
            qinv(2:4) = -qinv(2:4);
        end
    end
end
