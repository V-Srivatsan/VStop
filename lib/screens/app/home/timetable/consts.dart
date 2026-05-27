const slots = [
  (
    ["A1", "F1", "D1", "TB1", "TG1", "S11", "A2", "F2", "D2", "TB2", "TG2", "S3"],
    ["L1", "L2", "L3", "L4", "L5", "L6", "L31", "L32", "L33", "L34", "L35", "L36"],
  ),
  (
    ["B1", "G1", "E1", "TC1", "TAA1", "-", "B2", "G2", "E2", "TC2", "TAA2", "S1"],
    ["L7", "L8", "L9", "L10", "L11", "L12", "L37", "L38", "L39", "L40", "L41", "L42"],
  ),
  (
    ["C1", "A1", "F1", "TD1", "TBB1", "-", "C2", "A2", "F2", "TD2", "TBB2", "S4"],
    ["L13", "L14", "L15", "L16", "L17", "L18", "L43", "L44", "L45", "L46", "L47", "L48"],
  ),
  (
    ["D1", "B1", "G1", "TE1", "TCC1", "-", "D2", "B2", "G2", "TE2", "TCC2", "S2"],
    ["L19", "L20", "L21", "L22", "L23", "L24", "L49", "L50", "L51", "L52", "L53", "L54"],
  ),
  (
    ["E1", "C1", "A1", "TF1", "TDD1", "S15", "E2", "C2", "A2", "TF2", "TDD2", "-"],
    ["L25", "L26", "L27", "L28", "L29", "L30", "L55", "L56", "L57", "L58", "L59", "L60"],
  )
];

const theory = [
  (Duration(hours: 8, minutes: 0), Duration(hours: 8, minutes: 50)),
  (Duration(hours: 8, minutes: 55), Duration(hours: 9, minutes: 45)),
  (Duration(hours: 9, minutes: 50), Duration(hours: 10, minutes: 40)),
  (Duration(hours: 10, minutes: 45), Duration(hours: 11, minutes: 35)),
  (Duration(hours: 11, minutes: 40), Duration(hours: 12, minutes: 30)),
  (Duration(hours: 12, minutes: 35), Duration(hours: 13, minutes: 25)),

  (Duration(hours: 14, minutes: 0), Duration(hours: 14, minutes: 50)),
  (Duration(hours: 14, minutes: 55), Duration(hours: 15, minutes: 45)),
  (Duration(hours: 15, minutes: 50), Duration(hours: 16, minutes: 40)),
  (Duration(hours: 16, minutes: 45), Duration(hours: 17, minutes: 35)),
  (Duration(hours: 17, minutes: 40), Duration(hours: 18, minutes: 30)),
  (Duration(hours: 18, minutes: 35), Duration(hours: 19, minutes: 25)),
], lab = [
  (Duration(hours: 8, minutes: 0), Duration(hours: 8, minutes: 50)),
  (Duration(hours: 8, minutes: 50), Duration(hours: 9, minutes: 40)),
  (Duration(hours: 9, minutes: 50), Duration(hours: 10, minutes: 40)),
  (Duration(hours: 10, minutes: 40), Duration(hours: 11, minutes: 30)),
  (Duration(hours: 11, minutes: 40), Duration(hours: 12, minutes: 30)),
  (Duration(hours: 12, minutes: 30), Duration(hours: 13, minutes: 20)),

  (Duration(hours: 14, minutes: 0), Duration(hours: 14, minutes: 50)),
  (Duration(hours: 14, minutes: 50), Duration(hours: 15, minutes: 40)),
  (Duration(hours: 15, minutes: 50), Duration(hours: 16, minutes: 40)),
  (Duration(hours: 16, minutes: 40), Duration(hours: 17, minutes: 30)),
  (Duration(hours: 17, minutes: 40), Duration(hours: 18, minutes: 30)),
  (Duration(hours: 18, minutes: 30), Duration(hours: 19, minutes: 20)),
];