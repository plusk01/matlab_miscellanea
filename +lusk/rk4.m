function y = rk4(y, t, dt, f)
%RK4 Runge-Kutta 4th Order
%   Integrates ODE of the form: dy/dt = f(y,t).

if nargin('f') == 1
    h = @(y, t) f(y, 0);
elseif nargin('f') == 2
    h = @(y, t) f(y, t);
else
    error('f must be of form f(y,t) or f(y)');
end

k1 = dt * h(y, t);
k2 = dt * h(y + 0.5 * k1, t + 0.5 * dt);
k3 = dt * h(y + 0.5 * k2, t + 0.5 * dt);
k4 = dt * h(y + k3, t + dt);
y = y + 1/6 * (k1 + 2*k2 + 2*k3 + k4);

end

