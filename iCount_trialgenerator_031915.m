function [blockorder,learninglr] = iCount_trialgenerator_031915()

counter1a = 0;
counter1b = 0;
counter1c = 0;
vector1 = zeros(1,12);

while counter1a<3
    a = rand(1);
    b = randi(12);
    if vector1(b)==0 && a>.5
        vector1(b)=1;
        counter1a = counter1a+1;
    end
end
while counter1b<3
    a = rand(1);
    b = randi(12);
    if vector1(b)==0 && a>.5
        vector1(b)=2;
        counter1b = counter1b+1;
    end
end
while counter1c<3
    a = rand(1);
    b = randi(12);
    if vector1(b)==0 && a>.5
        vector1(b)=3;
        counter1c = counter1c+1;
    end
end
blockorder = vector1;

fractallf = double.empty;

counter2=0;
vector2=zeros(1,72);
while counter2<36
    a=rand(1);
    b=randi(72);
    if vector2(b)==0 && a>.5
        vector2(b)=1;
        counter2=counter2+1;
    end
end
learninglr = vector2;

end