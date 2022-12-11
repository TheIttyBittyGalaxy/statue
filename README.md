# 🧱 Statue

**_A high level programming language for hobbists that is dedicated to structure_**

## 📜 Design Pillars

-   **Simple yet expressive**: be a simple, expressive, high-level language, that enables experienced programmers to do a lot with a little.
-   **Static analysis as a feature**: aim to have as much _useful_ static analysis as possible. When error checking, the language should report as many true positives as is helpful but with zero false negatives.
-   **Support the creative process**: support an iterative (and perhaps slightly ad-hoc) approach to development.
-   **Veritile out the box**: suitable for creating lots of different kinds of programs and for deployment in a range of different contexts.
-   **Lightweight-ish**: remain fairly lightweight, prefering expressive/high-level features that don't carry significant or unmanagable overhead.

## 💡 Motivation

As a hobbyist programmer, I really like simplictity of programming with Lua. However, my two biggest pain points with it are that there is almost no static analysis, and that you can't make it do much on it's own. And that's fair enough, it was a languaged designed to write small scripts embedded into existing environments. Inspired by my experience in Lua, and the recent uptick in critical conversations about how to make _useful_ programming languages, I've been inspired to make a programming language inspired by this.

The idea feels solid enough to me that I'd like to put some effort towards it. By all means, feel free to contribute code, thoughts, and ideas!

## 💾 Sample Code

```statue
struct vector
    num x
    num y
    mag -> sqrt(x^2 + y^2)
end

def vector a + vector b -> vector [x: a.x + b.x, y: a.y + b.y]

def vector a * num s -> vector [x: a.x * s, y: a.y * s]

funct main()
    let origin = vector [x: 10, y: 0]
    my_pos = vector [x: 5.5, y: -4]

    let offset = my_pos - origin

    print("My vector has a magnitude of [offset.mag] units")
    if offset.mag < 0 do // Notice: vector.mag can never be < 0
        print("woh! how did that happen?")
    end
end
```

## 🗺️ What Am I Looking At?

### `lua-compiler`

This compiler, written in Lua, takes Statue source code and compiles it into C++. This is the "stage 0", which can be used to bootstrap the selfhost compiler.

### `selfhost-compiler`

This compiler, written in Statue, takes Statue source code and compiles it into C++. Once you compile it with the lua compiler, it is able to compile itself!

_(at least, that's the goal- it doesn't actually exist yet!)_
