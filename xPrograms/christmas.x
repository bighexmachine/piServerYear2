array nextLetter[16];
val numLetters = 17;
array letters[numLetters];

proc main() is
  {
    letters[0] :=  [ #b0000000000000000
                   , #b0000000000000000
                   , #b0001111111111000
                   , #b0011111111111100
                   , #b0011000110001100
                   , #b0011000110001100
                   , #b0011000110001100
                   , #b0011000110001100
                   , #b0011000000001100
                   , #b0011000000001100
                   , #b0011000000001100
                   , #b0011000000001100
                   , #b0011000000001100
                   , #b0011000000001100
                   , #b0000000000000000
                   , #b0000000000000000
                   ];

    letters[1] := [ #b0000000000000000
         , #b0000000000000000
         , #b0011111111111000
         , #b0011111111111000
         , #b0011000000000000
         , #b0011000000000000
         , #b0011000000000000
         , #b0011111100000000
         , #b0011111100000000
         , #b0011000000000000
         , #b0011000000000000
         , #b0011000000000000
         , #b0011111111111000
         , #b0011111111111000
         , #b0000000000000000
         , #b0000000000000000
         ];
    letters[2] := [ #b0000000000000000
          , #b0011111111100000
          , #b0011000000011000
          , #b0011000000011000
          , #b0011000000001100
          , #b0011000000011000
          , #b0011000000110000
          , #b0011000001100000
          , #b0011111111000000
          , #b0011000001100000
          , #b0011000000110000
          , #b0011000000011000
          , #b0011000000001100
          , #b0011000000001100
          , #b0011000000001100
          , #b0000000000000000
          ];

    letters[3] := letters[2];

    letters[4] := [ #b0000000000000000
         , #b0110000000000110
         , #b0110000000000110
         , #b0011000000001100
         , #b0001100000011000
         , #b0000110000110000
         , #b0000011001100000
         , #b0000001111000000
         , #b0000000110000000
         , #b0000000110000000
         , #b0000000110000000
         , #b0000000110000000
         , #b0000000110000000
         , #b0000000110000000
         , #b0000000110000000
         , #b0000000000000000
         ];

    letters[5] :=  [ #b0000000000000000
          , #b0000000000000000
          , #b0000000000000000
          , #b0000000000000000
          , #b0000000000000000
          , #b0000000000000000
          , #b0000000000000000
          , #b0000000000000000
          , #b0000000000000000
          , #b0000000000000000
          , #b0000000000000000
          , #b0000000000000000
          , #b0000000000000000
          , #b0000000000000000
          , #b0000000000000000
          , #b0000000000000000
          ];

    letters[6] := [ #b0000000000000000
         , #b0000000000000000
         , #b0000001111110000
         , #b0000111111111000
         , #b0001111000001100
         , #b0011100000000000
         , #b0011000000000000
         , #b0011000000000000
         , #b0011000000000000
         , #b0011000000000000
         , #b0011100000000000
         , #b0001111000001100
         , #b0000111111111000
         , #b0000001111110000
         , #b0000000000000000
         , #b0000000000000000
         ];

    letters[7] := [ #b0000000000000000
          , #b0111000000001110
          , #b0111000000001110
          , #b0111000000001110
          , #b0111000000001110
          , #b0111000000001110
          , #b0111000000001110
          , #b0111111111111110
          , #b0111111111111110
          , #b0111000000001110
          , #b0111000000001110
          , #b0111000000001110
          , #b0111000000001110
          , #b0111000000001110
          , #b0111000000001110
          , #b0000000000000000
          ];

    letters[8] := letters[3];

    letters[9] := [ #b0000000000000000
         , #b0011111111111100
         , #b0011111111111100
         , #b0000000110000000
         , #b0000000110000000
         , #b0000000110000000
         , #b0000000110000000
         , #b0000000110000000
         , #b0000000110000000
         , #b0000000110000000
         , #b0000000110000000
         , #b0000000110000000
         , #b0000000110000000
         , #b0011111111111100
         , #b0011111111111100
         , #b0000000000000000
         ];

    letters[10] :=[ #b0000000000000000
         , #b0000000000000000
         , #b0000011111111000
         , #b0000111111111100
         , #b0001111000001100
         , #b0011110000000100
         , #b0001111000000000
         , #b0000111111100000
         , #b0000011111110000
         , #b0000000001111000
         , #b0010000000111100
         , #b0011000001111000
         , #b0011111111110000
         , #b0001111111100000
         , #b0000000000000000
         , #b0000000000000000
         ];

    letters[11] := [ #b0000000000000000
         , #b0011111111111100
         , #b0011111111111100
         , #b0000000110000000
         , #b0000000110000000
         , #b0000000110000000
         , #b0000000110000000
         , #b0000000110000000
         , #b0000000110000000
         , #b0000000110000000
         , #b0000000110000000
         , #b0000000110000000
         , #b0000000110000000
         , #b0000000110000000
         , #b0000000110000000
         , #b0000000000000000
         ];

    letters[12] := letters[0];

    letters[13] :=[ #b0000000000000000
         , #b0000000110000000
         , #b0000000110000000
         , #b0000001111000000
         , #b0000001111000000
         , #b0000011001100000
         , #b0000011001100000
         , #b0000110000110000
         , #b0000110000110000
         , #b0001111111111000
         , #b0001111111111000
         , #b0011000000001100
         , #b0011000000001100
         , #b0110000000000110
         , #b0110000000000110
         , #b0000000000000000
         ];

    letters[14] := letters[10];

    letters[15] := [ #b0000000000000000
            , #b0000000110000000
            , #b0000000110000000
            , #b0000000110000000
            , #b0000000110000000
            , #b0000000110000000
            , #b0000000110000000
            , #b0000000110000000
            , #b0000000110000000
            , #b0000000110000000
            , #b0000000110000000
            , #b0000000110000000
            , #b0000000000000000
            , #b0000000110000000
            , #b0000000110000000
            , #b0000000000000000
            ];

    letters[16] := [ #b0000001111000000
       , #b0000111111110000
       , #b0001111111111000
       , #b0011111111111100
       , #b0111001111001110
       , #b0111001111001110
       , #b1111111111111111
       , #b1111111111111111
       , #b1111111111111111
       , #b1111111111111111
       , #b1111111111111111
       , #b0111011111101110
       , #b0011100110011100
       , #b0001111001111000
       , #b0000111111110000
       , #b0000001111000000
       ];

    while true do
    {
      rotateThroughWord();
      wink()
    }
  }

proc wink() is
{
  framebuff[11] := #b0111001111111110;
  delay();
  framebuff[10] := #b0111001111111110;
  delay();
  framebuff[10] := #b0111001111001110;
  delay();
  framebuff[11] := #b0111001111001110;
  delay()
}


proc rotateThroughWord() is
  var letterCounter;
  {
    letterCounter:=0;
    while letterCounter < numLetters do
    {
      swapInNextLetter(letterCounter);
      letterCounter := letterCounter + 1
    }
  }

proc swapInNextLetter(nextLetterIndex) is
  var columnCounter;
  var rowCounter;
  var rowTmp;
  {
    copyImage(letters[nextLetterIndex], nextLetter);
    columnCounter := 0;
    while columnCounter < 16 do
    {
      rowCounter := 0;
      while rowCounter < 16 do
      {
        framebuff[rowCounter] := framebuff[rowCounter] + framebuff[rowCounter];
        if nextLetter[rowCounter] < 0 then framebuff[rowCounter] := framebuff[rowCounter] + 1 else skip;
        nextLetter[rowCounter] := nextLetter[rowCounter] + nextLetter[rowCounter];
        rowCounter := rowCounter + 1
      };
      columnCounter := columnCounter + 1
    }
  }

proc copyImage(s, dest) is
  var n;
  {
    n := 0;
    while n < 16 do
    {
      dest[15-n] := s[n];
      n := n + 1
    }
  }

proc delay() is
  var n;
  {
    n := 0;
    while n < 100 do n := n + 1
  }
