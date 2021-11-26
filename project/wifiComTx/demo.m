Fs = 8000;
t = 1/Fs*(0:1:3*Fs-1);
f = 300;
y = sin(2*pi*f*t);
sound(y,Fs);