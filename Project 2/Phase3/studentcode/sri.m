function [X, Z] = sri(sensor, vic, p0,p1,p2,p3,p4)
% EKF1 Extended Kalman Filter with Vicon velocity as inputs
%
% INPUTS:
%   sensor - struct stored in provided dataset, fields include
%          - is_ready: logical, indicates whether sensor data is valid
%          - t: sensor timestamp
%          - rpy, omg, acc: imu readings
%          - img: uint8, 240x376 grayscale image
%          - id: 1xn ids of detected tags
%          - p0, p1, p2, p3, p4: 2xn pixel position of center and
%                                four corners of detected tags
%            Y
%            ^ P3 == P2
%            | || P0 ||
%            | P4 == P1
%            o---------> X
%   vic    - struct for storing vicon linear velocity in world frame and
%            angular velocity in body frame, fields include
%          - t: vicon timestamp
%          - vel = [vx; vy; vz; wx; wy; wz]
%   varargin - any variables you wish to pass into the function, could be
%              a data structure to represent the map or camera parameters,
%              your decision. But for the purpose of testing, since we don't
%              know what inputs you will use, you have to specify them in
%              init_script by doing
%              ekf1_handle = ...
%                  @(sensor, vic) ekf1(sens:12or, vic, your input arguments);
%
% OUTPUTS:
% X - nx1 state of the quadrotor, n should be greater or equal to 6
%     the state should be in the following order
%     [x; y; z; qw; qx; qy; qz; other states you use]
%     we will only take the first 7 rows of X
% OPTIONAL OUTPUTS:
% Z - mx1 measurement of your pose estimator, m shoulb be greater or equal to 7
%     the measurement should be in the following order
%     [x; y; z; qw; qx; qy; qz; other measurement you use]
%     note that this output is optional, it's here in case you want to log your
%     measurement

persistent flag sensor_old Xk Pk

if isempty(flag)
    sensor_old=sensor;

%    [vel, omg] = estimate_vel(sensor);
    [pos, q] = estimate_pose(sensor,p0,p1,p2,p3,p4);

    [phi,theta,psi]=RotToRPY_ZXY(QuatToRot(q));
     
    G=[cosd(theta) 0 -cosd(phi)*sind(theta); 
       0           1              sind(phi); 
       sind(theta) 0 -cosd(phi)*cosd(theta)]; %w=G(q)*q_dot
    
    vicvel=vic.vel(1:3);    vicomg=vic.vel(4:6);
    q_dot=G\vicomg;

    Xk=[pos;phi;theta;psi]; Pk=eye(6);
    
    flag=1;
    return;
end

%% CURRENT STATE MEASUREMENT%%

[pos, q] = estimate_pose(sensor,p0,p1,p2,p3,p4);

[phi,theta,psi]=RotToRPY_ZXY(QuatToRot(q));
     
G=[cosd(theta) 0 -cosd(phi)*sind(theta); 
   0           1              sind(phi); 
   sind(theta) 0 -cosd(phi)*cosd(theta)]; %w=G(q)*q_dot

vicvel=vic(7:9);    vicomg=vic(10:12);
q_dot=G\vicomg;

Y=[pos;phi;theta;psi]; Uk=[vicvel;9.81;q_dot]; delT=sensor.t-sensor_old.t;

%% NEW STATE PREDICTION %%

Xk_1=Xk;    Pk_1=Pk;

R=eye(6);   %will have to tune this

A=eye(6);       %delT is time step! Need to bring this from somehere!

B=eye(7)*delT;  B(4,:)=[];
B(3,4)=0.5*delT^2;

Wk=zeros(6,1); Qk=zeros(6,1);

Xkp=A*Xk_1+B*Uk+Wk;     Pkp=A*Pk_1*transpose(A)+Qk;

%% UPDATING AND KALMAN GAIN %%

KG=Pkp./(Pkp+R);

KG(isnan(KG))=0;

Xk=Xkp+KG*(Y-Xkp);
Xk(4:7)=RotToQuat(RPYtoRpt_ZXY(Xk(4:6)));
Pk=(eye(6)-KG)*Pkp;

sensor_old=sensor;

X = [Xk];
Z = zeros(7,1);

end