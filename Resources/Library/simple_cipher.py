"""Question 6 - simpleCipher on the A-Z alphabet wheel.

Robot keyword library (and a plain CLI) used by Testcase/Q6_Simple_Cipher.robot.
"""
ALPHABET_SIZE = 26
FIRST_LETTER = ord("A")


def simpleCipher(encrypted, k):
    """Robot keyword `Simple Cipher`. Decrypt ``encrypted`` by walking k letters counter-clockwise on the wheel.

    Counter-clockwise on the A-Z wheel = backwards through the alphabet, so each
    letter moves from ``c`` to ``c - k``, wrapping A -> Z. ``k`` is taken modulo 26,
    which also makes a negative or very large k behave.

    >>> simpleCipher('VTAOG', 2)
    'TRYME'
    """
    shift = int(k) % ALPHABET_SIZE
    decrypted = []
    for char in str(encrypted):
        if "A" <= char <= "Z":
            position = ord(char) - FIRST_LETTER
            decrypted.append(chr((position - shift) % ALPHABET_SIZE + FIRST_LETTER))
        else:
            # the assignment promises A-Z only; anything else is passed through
            decrypted.append(char)
    return "".join(decrypted)


if __name__ == "__main__":
    for text, shift in (("VTAOG", 2), ("ABC", 1), ("ZAB", 26), ("HELLO", 0)):
        print(f"simpleCipher({text!r}, {shift}) = {simpleCipher(text, shift)!r}")
