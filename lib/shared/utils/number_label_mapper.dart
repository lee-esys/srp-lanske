String circledNumber(int number) {
  // 1-20: ①..⑳
  if (number >= 1 && number <= 20) {
    return String.fromCharCode(0x2460 + (number - 1));
  }

  // 21-35: ㉑..㉟
  if (number >= 21 && number <= 35) {
    return String.fromCharCode(0x3251 + (number - 21));
  }

  // 36-50: ㊱..㊿
  if (number >= 36 && number <= 50) {
    return String.fromCharCode(0x32B1 + (number - 36));
  }

  return number.toString();
}

String blackCircledNumber(int number) {
  // 1-10: ❶..❿
  if (number >= 1 && number <= 10) {
    return String.fromCharCode(0x2776 + (number - 1));
  }

  // 11-20: ⓫..⓴
  if (number >= 11 && number <= 20) {
    return String.fromCharCode(0x24EB + (number - 11));
  }

  return number.toString();
}

String participantLabelNumber(int index) {
  return (index + 1).toString();
}
