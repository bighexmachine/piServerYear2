array doubleBuffer[16];

proc main() is
 |positions of player bars|
 var posA;
 var posB;
 |position of ball|
 var x;
 var y;
 |direction of ball|
 var xs;
 var ys;
 |loop and value vars|
 var i;
 var j;
 var m;
 |0:no-one, 1:player 1, 2:player 2|
 var winner;
  {
    initNumbers();

    sRand(93);
    while true do
    {
      winner := 0;
      posA := 7;
      posB := 7;
      x := 8;
      y := 3;
      xs := genRand(2);
      if xs=0 then xs:= #FFFF else skip;
      ys := genRand(5)-2;

      memzero(doubleBuffer, 16);

      | initialise the position of the paddles|
      doubleBuffer[posA]   := #8001;
      doubleBuffer[posA+1] := #8001;
      doubleBuffer[posA+2] := #8001;
      doubleBuffer[posA+3] := #8001;

      doubleBuffer[y]:=doubleBuffer[y]+lsh(1,x);
      displayBitmap(doubleBuffer);

      while winner=0 do
      {
        |move ball|
        doubleBuffer[y]:=doubleBuffer[y]-lsh(1,x);
        x:=x+xs;
        y:=y+ys;
        if x=15 then
        {
          if ((y-posA)<0) or ((posA+4)<y) then winner:=2 else xs:=0-xs
        }
        else skip;
        if x=0 then
        {
          if ((y-posB)<0) or ((posB+4)<y) then winner:=1 else xs:=0-xs
        }
        else skip;
        if (y=15) or (y=14) or (y=0) or (y=1) then ys:=0-ys else skip;
        doubleBuffer[y]:=doubleBuffer[y]+lsh(1,x);

        |move bars|
        j:=150;
        while j > 0 do
          var v;
        {
          0?v;
          |get new position|
          if (v=2) and (posA<12) then
          {
            doubleBuffer[posA+3]:=doubleBuffer[posA+3]-#8000;
            posA:=posA-1;
            doubleBuffer[posA]:=doubleBuffer[posA]+#8000
          }
          else skip;

          if (v<0) and (posA>0) then
          {
            doubleBuffer[posA]:=doubleBuffer[posA]-#8000;
            posA:=posA+1;
            doubleBuffer[posA+3]:=doubleBuffer[posA+3]+#8000
          }
          else skip;

          1?v;
          |get new position|
          if (v=2) and (posB<12) then
          {
            doubleBuffer[posB+3]:=doubleBuffer[posB+3]-#0001;
            posB:=posB-1;
            doubleBuffer[posB]:=doubleBuffer[posB]+#0001
          }
          else skip;

          j:=j-1
        };

        displayBitmap(doubleBuffer)
      };
      i:=0;
      while i<4 do
      {
        displayBitmap(getBitmapForChar(winner + '0'));
        longdelay();
        clearDisplay();
        longdelay();
        i:=i+1
      }
    }
  }

proc rotateFrameBuff() is
  var n;
  var w;
{ n := 0;
  while n < 16 do
  { w := doubleBuffer[n];
    if w < 0
    then
      doubleBuffer[n] := w + w + 1
    else
      doubleBuffer[n] := w + w;
    n := n + 1
  }
}
