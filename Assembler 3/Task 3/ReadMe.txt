a:b * c:d = e:f
// goes to
e:f = b*d;
x:y = a*d;  e += y;
x:y = b*c;  e += y;


high1:low1 * high2:low2 = resH:resL
resH:resL = low1 * low2;
highTmp:lowTmp = high1 * low2;  resH += lowTmp;
highTmp:lowTmp = low1 * high2; resH += lowTmp;