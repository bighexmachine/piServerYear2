array nextLetter[16];

val numLetters = 12;
array letters[12];

proc main() is
{
  letters := ['H', 'E', 'L', 'L', 'O', ' ', 'W', 'O', 'R', 'L', 'D', '!'];
  clearDisplay();
  initAlphabet();
  while true do
  {
    rotateThroughWord()
  }
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
  var letter;
{
  copyBitmapForChar(letters[nextLetterIndex], nextLetter);

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
