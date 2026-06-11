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
    ["E1", "C1", "TA1", "TF1", "TDD1", "S15", "E2", "C2", "TA2", "TF2", "TDD2", "-"],
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

const slot_loc = {
  "A1": [(0, 0), (2, 1)], "A2": [(0, 6), (2, 7)], "TA1": [(4, 2)], "TA2": [(4, 8)], "TAA1": [(1, 4)], "TAA2": [(1, 10)],
  "B1": [(1, 0), (3, 1)], "B2": [(1, 6), (3, 7)], "TB1": [(0, 3)], "TB2": [(0, 9)], "TBB1": [(2, 4)], "TBB2": [(2, 10)],
  "C1": [(2, 0), (4, 1)], "C2": [(2, 6), (4, 7)], "TC1": [(1, 3)], "TC2": [(1, 9)], "TCC1": [(3, 4)], "TCC2": [(3, 10)],
  "D1": [(0, 2), (3, 0)], "D2": [(0, 8), (3, 6)], "TD1": [(2, 3)], "TD2": [(2, 9)], "TDD1": [(4, 4)], "TDD2": [(4, 10)],
  "E1": [(1, 2), (4, 0)], "E2": [(1, 8), (4, 6)], "TE1": [(3, 3)], "TE2": [(3, 9)],
  "F1": [(0, 1), (2, 2)], "F2": [(0, 7), (2, 8)], "TF1": [(4, 3)], "TF2": [(4, 9)],
  "G1": [(1, 1), (3, 2)], "G2": [(1, 7), (3, 8)], "TG1": [(0, 4)], "TG2": [(0, 10)],
  "L1": [(0, 0)], "L2": [(0, 1)], "L3": [(0, 2)], "L4": [(0, 3)], "L5": [(0, 4)], "L6": [(0, 5)],
  "L7": [(1, 0)], "L8": [(1, 1)], "L9": [(1, 2)], "L10": [(1, 3)], "L11": [(1, 4)], "L12": [(1, 5)],
  "L13": [(2, 0)], "L14": [(2, 1)], "L15": [(2, 2)], "L16": [(2, 3)], "L17": [(2, 4)], "L18": [(2, 5)],
  "L19": [(3, 0)], "L20": [(3, 1)], "L21": [(3, 2)], "L22": [(3, 3)], "L23": [(3, 4)], "L24": [(3, 5)],
  "L25": [(4, 0)], "L26": [(4, 1)], "L27": [(4, 2)], "L28": [(4, 3)], "L29": [(4, 4)], "L30": [(4, 5)],
  "L31": [(0, 6)], "L32": [(0, 7)], "L33": [(0, 8)], "L34": [(0, 9)], "L35": [(0, 10)], "L36": [(0, 11)],
  "L37": [(1, 6)], "L38": [(1, 7)], "L39": [(1, 8)], "L40": [(1, 9)], "L41": [(1, 10)], "L42": [(1, 11)],
  "L43": [(2, 6)], "L44": [(2, 7)], "L45": [(2, 8)], "L46": [(2, 9)], "L47": [(2, 10)], "L48": [(2, 11)],
  "L49": [(3, 6)], "L50": [(3, 7)], "L51": [(3, 8)], "L52": [(3, 9)], "L53": [(3, 10)], "L54": [(3, 11)],
  "L55": [(4, 6)], "L56": [(4, 7)], "L57": [(4, 8)], "L58": [(4, 9)], "L59": [(4, 10)], "L60": [(4, 11)],
  "S1": [(1, 11)], "S2": [(3, 11)], "S3": [(0, 11)], "S4": [(2, 11)], "S11": [(0, 5)], "S15": [(4, 5)],
};