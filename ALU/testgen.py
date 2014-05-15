AND='000'
OR='001'
XOR='010'
SHCL='011'
SHCR='100'
NOT='101'
SUB='110'
ADD='111'
oth='0'
f=open("PLDtesting.txt",'w');



def operation(o,A,B,cin):
    if o==AND:
        return (A&B,cin);
    if o==OR:
        return (A|B,cin);
    if o==XOR:
        return (A^B,cin);
    if o==NOT:
        return (~A&0xF,cin);
    if o==SHCL:
        A *= 2;
        A += cin;
        cout = (A>>4)&1
        return (A&0xF,cout);
    if o==SHCR:
        cout = A&1;
        A //= 2;
        A += cin<<3;
        return (A,cout);
    if o==ADD:
        out=A+B+cin
        cout=(out>>4)&1;
        return (out&0xF,cout);
    if o==SUB:
        out=A+(~B+1)%16+ ~cin
        cout= out>>4&1;
        return (out&0xF,cout);
    
def testGen(op):
    for cin in [0,1]:
        for A in range(0x10):
            for B in range(0x10):
                a = bin(A)[2:]; b = bin(B)[2:];
                a=a.rjust(4,'0'); b=b.rjust(4,'0'); #add 0 padding
                out,carry=operation(op,A,B,cin);
                out=bin(out)[2:].rjust(4,'0').replace('0','L').replace('1','H');
                carry=str(carry).replace('0','L').replace('1','H');
                print(op,a,b,cin,oth,out,carry,sep='',file=f);

testGen(AND);
testGen(OR);
testGen(XOR);
testGen(NOT);
testGen(SHCL);
testGen(SHCR);
testGen(ADD);



f.close();
f2=open("PLDExpression.txt",mode='w');
def genLogic(op):
    for A in range(0x10):
        for B in range(0x10):
            for cin in range(2):
                a = bin(A)[2:]; b = bin(B)[2:];
                a=a.rjust(4,'0'); b=b.rjust(4,'0'); #add 0 padding
                out,cout=operation(op,A,B,cin);
                out=bin(out)[2:].rjust(4,'0');
                print("'b'",op,a,b,cin," => 'b'",out,cout,";",sep='',file=f2);


f2.close();

                

