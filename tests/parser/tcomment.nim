import ccspkg/[test_utils, ast]

testParse("/* hello */", newSheet @[newComment " hello "])


