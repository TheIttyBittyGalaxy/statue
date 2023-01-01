# 🧱 Statue

**_A high-level programming language for hobbyists that is dedicated to structure_**

## 📜 Design Pillars

-   **Simple yet expressive**: be a simple, expressive, high-level language, that lets experienced programmers to do a lot with a little.
-   **Awesome static analysis**: have as much _useful_ static analysis as possible, but still with zero false negative error reporting.
-   **Support the creative process**: support an iterative (and perhaps slightly ad-hoc) approach to development.
-   **Versatile**: suitable for creating lots of different kinds of programs and deployable across a range of contexts.
-   **Lightweight-ish**: maintain quick compile and run times by opting for expressive features that don't carry significant or unnegotiable overhead.

## 💡 Motivation

As a hobbyist programmer I really like the simplicity of Lua, particularly when I'm coding with my "creative hat” on rather than an engineering mindset. However, my two biggest pain points with it are that there is almost no static analysis, and that you can't do much with it on its own. (And that's fair enough, it was a language designed to write small scripts embedded into existing environments!)

Inspired by my experience in Lua, and the recent uptick in critical conversations about how to make _useful_ programming languages, I've had lots of programming language ideas swirling around in my head. This is my attempt to pull of those ideas together and turn them into something concrete. If I like the result, hopefully I'll use the language to actually make things too!

The design pillars aren't set in stone, but the general direction feels solid enough to me that I'd like to put some effort towards it. Feel free to contribute code if you like, or thoughts and ideas are also welcome! Just fork the repo or open an issue, whatever works best :)

## 💾 Sample Code

```statue
struct vector
    num x
    num y
    mag -> sqrt(x^2 + y^2)
end

def -vector a -> vector [x: -a.x, y: -a.y]

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

This compiler, written in Statue, takes Statue source code and compiles it into C++. Once you compile it with the Lua compiler, it is able to compile itself!

_(at least, that's the goal- it doesn't actually exist yet!)_
