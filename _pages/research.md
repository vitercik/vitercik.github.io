---
layout: page
permalink: /research/
title: research
description: >-
  Summary of my research.
nav: true
nav_order: 2
---

## Overview

How can we use machine learning (ML) to improve optimization and decision-making while retaining the guarantees that make traditional algorithms trustworthy?

Optimization underpins many of society's most pressing challenges, from decarbonizing energy systems to allocating scarce medical resources. These problems are often NP-hard, and thus difficult to solve at scale. My goal is to improve optimization, decision-making, and algorithm design by leveraging data and ML, and to understand the algorithmic capabilities of large language models. I also study learning in markets and mechanism design, where strategic incentives shape decision-making. Across these domains, I aim to improve algorithmic performance while preserving rigorous guarantees.

## Learning-theoretic foundations of algorithm design

ML has strong potential in algorithm design, but it can also introduce risks: an algorithm that performs well on historical data may not generalize, and predictions about future inputs may be erroneous. I develop learning-theoretic methods that quantify these risks and characterize when data can be used reliably in algorithm design.

**Representative work:**

- [“How Much Data Is Sufficient to Learn High-performing Algorithms?”](https://arxiv.org/abs/1908.02894) (Balcan et al., JACM’24, STOC’21) provides broadly applicable generalization guarantees for configuring algorithms with ML.
- [“Algorithms with Calibrated Machine Learning Predictions”](https://arxiv.org/abs/2502.02861) (Shen et al., ICML’25) examines how algorithms can adapt to uncertainty about their inputs, characterized via calibration.

## Trustworthy artificial intelligence for discrete optimization

Artificial intelligence (AI) can be used to formulate and solve discrete optimization problems, but learned components can introduce failure modes that violate the guarantees that make traditional solvers trustworthy, such as feasibility and optimality. My research develops AI methods that speed up large-scale discrete optimization, while ensuring these critical guarantees are not sacrificed.

**Representative work:**

- AI is increasingly used to customize the optimization model provided to a solver, since a problem can be formulated in many ways, some faster to solve than others. [“EquivaMap”](https://arxiv.org/abs/2502.14760) (Zhai et al., ICML’25) develops methods to check if the customized model still faithfully represents the original problem.

## Algorithmic reasoning in AI systems

Large language models (LLMs) are increasingly asked to help perform tasks such as planning, scheduling, and resource allocation. In these high-stakes domains, we must be able to trust the resulting decisions. My research aims to analyze when, how, and why these systems can perform reliable multi-step reasoning, especially on complex combinatorial inputs.

**Representative work:**

- [“Can LLMs Reason Structurally? Benchmarking via the Lens of Data Structures”](https://arxiv.org/abs/2505.24069) (He et al., ICML’26) diagnoses models’ abilities to understand relationships such as order, connectivity, hierarchy, and composition, and to manipulate objects according to these relationships—a prerequisite for complex, multi-step decision-making.

## Learning in markets and mechanisms

Optimization algorithms are often core components of broader decision-making pipelines, where the consequences of algorithmic choices unfold in complex economic contexts. This thrust of my research focuses on _mechanism design_, which develops algorithms to guide groups of agents towards desired outcomes despite uncertainty and strategic incentives.

**Representative work:**

- [“Leveraging Reviews: Learning to Price with Buyer and Seller Uncertainty”](https://arxiv.org/abs/2302.09700) (Guo et al., OR’26, EC’23) develops pricing mechanisms when both sides of a market are learning from reviews: buyers use reviews to learn their values while the seller learns about demand.
