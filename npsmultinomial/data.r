library(tibble)
library(dplyr)

load_data <- function(N = 1000000, n = 10000) {
    softmax <- function(x) exp(x) / sum(exp(x))

    # Age
    age_values <- c("18–25", "26–35", "36–45", "46–55", "56–65", "66+")
    age_probabilities <- softmax(c(2, 3, 3, 2, 2, 1))

    # Seniority
    seniority_values <- c("6M", "1Y", "2Y", "3Y", "4Y", "5Y", "6Y+")
    seniority_probabilities <- softmax(c(3, 2, 2, 2, 1, 1, 1))

    # Score
    score_values <- seq(0, 10)
    score_probabilities <- softmax(c(1, 1, 1, 1, 2, 2, 2, 3, 3, 3, 4))

    # Generate a population
    population <- tibble(
        age = sample(age_values, N,
            prob = age_probabilities,
            replace = TRUE
        ),
        seniority = sample(seniority_values, N,
            prob = seniority_probabilities,
            replace = TRUE
        )
    )

    # Take a sample from the population
    sample <- population %>%
        sample_n(n) %>%
        mutate(score = sample(score_values, n,
            prob = score_probabilities,
            replace = TRUE
        )) %>%
        mutate(category = case_when(
            score < 7 ~ "detractor",
            score > 8 ~ "promoter",
            TRUE ~ "neutral"
        ))

    # Summarize the population
    population <- population %>%
        group_by(age, seniority) %>%
        count(name = "cell_size")

    # Summarize the sample
    sample <- sample %>%
        group_by(age, seniority) %>%
        summarize(
            detractors = sum(category == "detractor"),
            neutrals = sum(category == "neutral"),
            promoters = sum(category == "promoter")
        ) %>%
        mutate(cell_size = detractors + neutrals + promoters)

    # Bind counts of neutrals, detractors, and promoters (needed for brms)
    sample$cell_counts <- with(sample, cbind(detractors, neutrals, promoters))
    colnames(sample$cell_counts) <- c("detractor", "neutral", "promoter")

    # Remove unused columns
    sample <- sample %>% select(-detractors, -neutrals, -promoters)

    list(population = population, sample = sample)
}
