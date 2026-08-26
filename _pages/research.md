---
layout: page
permalink: /research/
title: research
description: >-
  Research on learning theory and algorithm design, machine learning for optimization and decision-making, algorithmic reasoning in AI systems, and learning in markets and mechanisms.
nav: true
nav_order: 2
---

My research studies how machine learning and learning theory can inform the design and analysis of algorithms for discrete optimization and decision-making. I am interested both in foundational questions—what can be learned from representative problem instances, and with what guarantees—and in methods that improve performance in structured settings. I also study how AI systems perform tasks requiring algorithmic reasoning and how learning interacts with markets and mechanisms.

## Learning-theoretic foundations of algorithm design

Many algorithms expose consequential choices, such as parameters, heuristics, branching rules, or portfolios of procedures, whose performance varies across problem instances. My work develops learning-theoretic tools for making these choices from representative instances while controlling overfitting. This includes understanding how much data is required, how the structure of an algorithm's performance affects generalization, and when common approaches to configuration or selection can fail.

- [**How Much Data Is Sufficient to Learn High-performing Algorithms?**](https://doi.org/10.1145/3676278) develops a general framework for determining when an algorithm's performance on a training set reliably reflects its expected performance on new inputs from the same distribution.
- [**Learning to Branch: Generalization Guarantees and Limits of Data-Independent Discretization**](https://doi.org/10.1145/3637840) studies how branching strategies for branch-and-bound can be tuned from sampled instances without overfitting, while identifying limitations of data-independent parameter grids.

Related work includes [accelerating algorithm selection for combinatorial partitioning problems](https://arxiv.org/abs/2402.14332) and analyzing the [learnability of cutting-plane choices in branch-and-cut](https://arxiv.org/abs/2204.07312).

## Machine learning for optimization and decision-making

Optimization and sequential decision problems often recur across related environments, creating opportunities for machine learning to inform how an algorithm acts. My work studies how to represent and use uncertainty in these settings, when machine-learning estimates improve performance, and what guarantees remain possible. The problems include online scheduling and matching, repeated optimization, and combinatorial optimization.

- [**Algorithms with Calibrated Machine Learning Predictions**](https://proceedings.mlr.press/v267/shen25f.html) develops online decision methods that use calibrated probability estimates to account for instance-specific uncertainty, with guarantees and experiments for ski rental and job scheduling.

Other representative work includes [MAGNOLIA](https://arxiv.org/abs/2406.05959), which uses graph neural networks to approximate value-to-go in online matching, and [Wait-Less](https://arxiv.org/abs/2412.09594), which studies offline tuning and re-solving for repeated online decisions.

## Algorithmic reasoning in AI systems

AI systems are increasingly asked to execute or support algorithmic tasks, but aggregate accuracy alone may not reveal whether they use relevant discrete structure or generalize beyond familiar settings. My work develops structured neural approaches to algorithmic problems and diagnostic evaluations of the capabilities and limitations of large language models. A central goal is to identify when these systems add value and where stronger foundations or evaluation methods are needed.

- [**Primal-Dual Neural Algorithmic Reasoning**](https://proceedings.mlr.press/v267/he25r.html) introduces a neural framework grounded in primal-dual approximation algorithms and evaluates it on covering problems, including tests on larger and out-of-distribution graphs.
- [**Can LLMs Reason Structurally? Benchmarking via the Lens of Data Structures**](https://arxiv.org/abs/2505.24069) introduces a diagnostic benchmark for evaluating how well large language models perform structural computations involving order, hierarchy, and connectivity.

Related work uses language models for [equivalence checking of optimization formulations](https://arxiv.org/abs/2502.14760) and [cold-start configuration of cutting-plane separators](https://arxiv.org/abs/2412.12038).

## Learning in markets and mechanisms

Decision-making in markets and mechanisms often occurs with limited information, while participants learn from observations and respond strategically. My work examines the resulting interactions among learning, incentives, pricing, and revenue. This includes guarantees for pricing and auctions, learning from incomplete feedback, and evaluating whether mechanisms satisfy their intended incentive properties.

- [**Leveraging Reviews: Learning to Price with Buyer and Seller Uncertainty**](https://pubsonline.informs.org/doi/abs/10.1287/opre.2023.0447) studies online pricing when buyers use reviews from similar customers to estimate value and the seller lacks information about arriving buyer types, developing a no-regret pricing algorithm with matching lower bounds.

Other representative work provides [generalization guarantees for multi-item profit maximization](https://arxiv.org/abs/1705.00243), studies [partially informed auctions](https://arxiv.org/abs/2202.10606), and develops methods for [estimating approximate incentive compatibility](https://arxiv.org/abs/1902.09413).

## Related materials

See my [publications]({{ '/publications/' | relative_url }}), [talks]({{ '/talks/' | relative_url }}), and [tutorials]({{ '/tutorials/' | relative_url }}) for more detail. I also teach courses on [AI for Algorithmic Reasoning and Optimization](https://vitercik.github.io/ai4algs_25/) and [Machine Learning for Discrete Optimization](https://vitercik.github.io/ml4do/).

_Last substantively updated: August 2026._
