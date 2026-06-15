# Week 3 Retrospective

## What Did I Learn This Week?

This week focused on communicating smart contract security concepts through technical writing and practical case studies.

I learned how to:

* Break down a security vulnerability into understandable sections.
* Explain oracle manipulation attacks from both a technical and economic perspective.
* Document a complete exploit lifecycle, including the vulnerable pattern, exploit path, root cause, and mitigation.
* Publish security research publicly and present findings in a professional format.
* Improve my ability to explain smart contract vulnerabilities without relying on code alone.

I also gained experience converting practical security work into a public writeup that can be understood by other developers and security researchers.

---

## What Was Hardest?

The most difficult part was not building the exploit itself but explaining it clearly.

Writing about:

* Why the vulnerability exists
* Why the attack works
* Why the fix is effective

required a deeper understanding than simply making the exploit pass in a test.

Another challenge was organizing the article in a way that remained technical while still being understandable to readers who were unfamiliar with oracle manipulation attacks.

---

## What Security Concept Became Clearer?

Oracle manipulation became significantly clearer.

Key takeaways:

* Liquidity pool reserves are not reliable price oracles.
* Spot prices can be manipulated through large trades.
* Flash loans make manipulation attacks economically feasible.
* Smart contracts can be vulnerable even when the Solidity code itself is correct.
* Security failures often originate from incorrect protocol assumptions rather than programming mistakes.

The distinction between a coding bug and an economic design flaw became much easier to understand.

---

## What Do I Still Not Fully Understand?

There are several areas that require deeper study:

* Time-Weighted Average Price (TWAP) oracle mechanisms.
* Advanced Chainlink oracle architecture.
* Cross-protocol oracle attacks.
* Multi-block oracle manipulation scenarios.
* Real-world DeFi exploits involving oracle failures.
* How professional auditors evaluate oracle security during audits.

These topics will be important areas of focus in future weeks.

---

## Biggest Lesson From Week 3

Building an exploit proves that a vulnerability exists.

Explaining the exploit clearly proves that I understand it.

Writing about a vulnerability forced me to understand the attack, the root cause, and the defense at a much deeper level than simply implementing the code.
