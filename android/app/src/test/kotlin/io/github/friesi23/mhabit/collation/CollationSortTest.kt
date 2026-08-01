package io.github.friesi23.mhabit.collation

import org.junit.Assert.assertEquals
import org.junit.Test

class CollationSortTest {

    @Test
    fun `empty list returns empty list`() {
        val result = sortByCollationKey(
            items = emptyList(),
            collationKeyOf = { _ -> error("should not be called") },
        )
        assertEquals(emptyList<String>(), result)
    }

    @Test
    fun `single item returns its id`() {
        val result = sortByCollationKey(
            items = listOf(CollationItem("id1", "hello")),
            collationKeyOf = { _ -> 0 },
        )
        assertEquals(listOf("id1"), result)
    }

    @Test
    fun `sorts by collation key ascending`() {
        val items = listOf(
            CollationItem("c", "ccc"),
            CollationItem("a", "aaa"),
            CollationItem("b", "bbb"),
        )
        // Simulate: "aaa" has key 0, "bbb" has key 1, "ccc" has key 2
        val keyOf = { s: String ->
            when (s) {
                "aaa" -> 0
                "bbb" -> 1
                "ccc" -> 2
                else -> error("unexpected value: $s")
            }
        }
        val result = sortByCollationKey(items, keyOf)
        assertEquals(listOf("a", "b", "c"), result)
    }

    @Test
    fun `already-sorted list stays sorted`() {
        val items = listOf(
            CollationItem("a", "aaa"),
            CollationItem("b", "bbb"),
            CollationItem("c", "ccc"),
        )
        val keyOf = { s: String ->
            when (s) {
                "aaa" -> 0
                "bbb" -> 1
                "ccc" -> 2
                else -> error("unexpected value: $s")
            }
        }
        val result = sortByCollationKey(items, keyOf)
        assertEquals(listOf("a", "b", "c"), result)
    }

    @Test
    fun `reverse-order list becomes sorted`() {
        val items = listOf(
            CollationItem("c", "ccc"),
            CollationItem("b", "bbb"),
            CollationItem("a", "aaa"),
        )
        val keyOf = { s: String ->
            when (s) {
                "aaa" -> 0
                "bbb" -> 1
                "ccc" -> 2
                else -> error("unexpected value: $s")
            }
        }
        val result = sortByCollationKey(items, keyOf)
        assertEquals(listOf("a", "b", "c"), result)
    }

    @Test
    fun `tie in collation key is broken by id`() {
        val items = listOf(
            CollationItem("y", "zzz"),
            CollationItem("x", "aaa"),
        )
        // Both have the same collation key → fall back to id compareTo
        val keyOf = { _: String -> 0 }
        val result = sortByCollationKey(items, keyOf)
        // "x" < "y" lexicographically
        assertEquals(listOf("x", "y"), result)
    }

    @Test
    fun `multiple ties broken by id order`() {
        val items = listOf(
            CollationItem("c", "ccc"),
            CollationItem("b", "bbb"),
            CollationItem("a", "aaa"),
        )
        // All have same key — sorted purely by id
        val keyOf = { _: String -> 0 }
        val result = sortByCollationKey(items, keyOf)
        assertEquals(listOf("a", "b", "c"), result)
    }

    @Test
    fun `partial ties — some same key some different`() {
        val items = listOf(
            CollationItem("x2", "xa"),
            CollationItem("y1", "ya"),
            CollationItem("x1", "xb"), // same top-level key as x2
        )
        // key: "ya"=0, "xa"=1 ("xb" also =1)
        val keyOf = { s: String ->
            when (s) {
                "ya" -> 0
                "xa", "xb" -> 1
                else -> error("unexpected value: $s")
            }
        }
        val result = sortByCollationKey(items, keyOf)
        // ya(0) first, then x1(id "x1") before x2(id "x2")
        assertEquals(listOf("y1", "x1", "x2"), result)
    }

    @Test
    fun `preserves original item identity — ids are correct`() {
        val items = listOf(
            CollationItem("id-first", "bbb"),
            CollationItem("id-second", "aaa"),
        )
        val keyOf = { s: String ->
            when (s) {
                "aaa" -> 0
                "bbb" -> 1
                else -> error("unexpected value: $s")
            }
        }
        val result = sortByCollationKey(items, keyOf)
        assertEquals(listOf("id-second", "id-first"), result)
    }

    @Test
    fun `items with identical value and same key keep input order (stable sort)`() {
        // Kotlin's sortedWith uses a stable sort (TimSort), so equal
        // elements preserve their original relative order.
        val items = listOf(
            CollationItem("first", "dup"),
            CollationItem("second", "dup"),
        )
        val keyOf = { _: String -> 0 }
        val result = sortByCollationKey(items, keyOf)
        assertEquals(listOf("first", "second"), result)
    }

    @Test
    fun `many items with varying keys`() {
        val items = (0 until 50).map { i ->
            CollationItem("id-$i", "value-${(49 - i)}")
        }
        val keyOf = { s: String -> s.removePrefix("value-").toInt() }
        val result = sortByCollationKey(items, keyOf)
        val expected = (0 until 50).map { "id-${49 - it}" }
        assertEquals(expected, result)
    }

    @Test
    fun `single character values sort by key`() {
        val items = ('Z' downTo 'A').map { c ->
            CollationItem(c.toString(), c.toString())
        }
        val keyOf = { s: String -> s[0].code }
        val result = sortByCollationKey(items, keyOf)
        val expected = ('A'..'Z').map { it.toString() }
        assertEquals(expected, result)
    }

    @Test
    fun `tie broken by id regardless of value case`() {
        val items = listOf(
            CollationItem("upper", "A"),
            CollationItem("lower", "a"),
        )
        val keyOf = { _: String -> 0 }
        val result = sortByCollationKey(items, keyOf)
        // "lower" < "upper" lexicographically
        assertEquals(listOf("lower", "upper"), result)
    }
}
