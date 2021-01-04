function Tv = Tact(T,v)
Tv = T(1:3,1:3) * v + repmat(T(1:3,4),1,size(v,2));
end