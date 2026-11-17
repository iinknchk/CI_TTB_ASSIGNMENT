"""Question 1 - duplicate items between two lists.

Robot keyword library (and a plain CLI) used by Testcase/Q1_Duplicate_Items.robot.
"""
from robot.api.deco import keyword


@keyword("Find Duplicate Items")
def find_duplicate_items(list_a, list_b):
    """Return the items of ``list_a`` that also appear in ``list_b``.

    Order follows ``list_a``, each duplicate is appended once, and the result is a
    new list - neither input list is changed. Lookup uses a set, so the whole
    thing is O(len(a) + len(b)) instead of the O(n*m) a nested loop would cost.

    | ${dup}= | Find Duplicate Items | ${LIST_A} | ${LIST_B} |
    """
    seen_in_b = set(list_b)
    duplicates = []
    for item in list_a:
        if item in seen_in_b and item not in duplicates:
            duplicates.append(item)
    return duplicates


@keyword("Find Duplicate Items Naive")
def find_duplicate_items_naive(list_a, list_b):
    """Same answer with a nested loop - kept to show the O(n*m) version."""
    duplicates = []
    for item_a in list_a:
        for item_b in list_b:
            if item_a == item_b and item_a not in duplicates:
                duplicates.append(item_a)
    return duplicates


if __name__ == "__main__":
    LIST_A = [1, 2, 3, 5, 6, 8, 9]
    LIST_B = [3, 2, 1, 5, 6, 0]
    print("List A      :", LIST_A)
    print("List B      :", LIST_B)
    print("Duplicates  :", find_duplicate_items(LIST_A, LIST_B))
