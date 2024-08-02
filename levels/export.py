from sys import argv
feed = None
if len(argv) < 2: feed = input("Enter output filename : ")
else: feed = argv[1]
with open("export.bin", "rb") as f:
  source = f.read()
payload, count, i = "", 0, 0
while len(source)-count:
  item = source[count]
  term = [byte == item for index, byte in enumerate(source[count:count+256])]
  if False not in term: term.append(False)
  term = term.index(False)
  if not i % 8: payload += "\n.db "
  else: payload += ", "
  payload += f"${hex(term-1)[2:].zfill(2)}, ${hex(item)[2:].zfill(2)}"
  i += 1;count += term
with open(f"{feed}.asm", "w") as f: 
  f.write(payload)

#  in shell type : py -m export "world-level"
