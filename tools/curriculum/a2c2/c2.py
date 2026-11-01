"""C2 lessons for convert_a2c2_v3.py. First option of every list is the correct answer."""


def build(ch, fill, bank):
    return {
        "c2-abstract": dict(
            tip="A distinction separates two ideas that are often mixed. “Privacy is a claim about who decides the boundary; secrecy can be that claim, or it can be a refusal to let a decision be seen.” “Less… than…” compares: “Freedom is less the absence of limits than the choice of limits.” “Worth keeping” means deserving to be kept.",
            read=("Who decides the boundary.", "How much people hide.", "What a rule says.", "Why a secret is kept."),
            listen=("The chance to choose which limits are worth keeping.", "The absence of every limit.", "The power to ignore all rules.", "The right to keep everything secret."),
            gram=[ch("less / than", "more / than", "less / as", "fewer / than", prompt="Choose the pair: Freedom is … the absence of limits … the choice of limits."),
                  ("worth", "worthy", "worthless", "worthed"), ("who", "whom", "whose", "whoever"), ("or", "nor", "than", "as")],
            tf=("Mina thinks privacy and secrecy mean the same thing.", False, "She separates privacy, a claim about who decides the boundary, from secrecy."),
            dict="Privacy is a claim about who decides the boundary.",
        ),
        "c2-interpret": dict(
            tip="Hold more than one reading of the same words. A pause can read as respect, doubt or refusal. “The sentence does not decide” its own meaning; “the history does the work.” Use “or” to list possibilities. A neat reading may feel decisive and still be wrong.",
            read=("The neatest reading.", "The longest reading.", "The oldest reading.", "The loudest reading."),
            listen=("The history between the speakers.", "The length of the pause.", "The loudness of the voice.", "The room they are in."),
            gram=[("or", "and", "but", "nor"), ("does not", "do not", "not", "is not"), ("does", "do", "is", "has"), ("and", "so that", "because", "nor")],
            tf=("Mina picks the neatest reading at once.", False, "She will not let the neatest reading win only because it is neat."),
            dict="The sentence does not decide; the history does the work.",
        ),
        "c2-debate": dict(
            tip="Grant a point and still refuse the leap. “I can grant the strongest version of your case and still reject the leap, because the step is untested.” “Agreement on the facts is not agreement on the conclusion.” Use “still” to show that you keep your position.",
            read=("Agreement on the facts.", "Agreement on the plan.", "Agreement on the date.", "Agreement on the budget."),
            listen=("The step between them is an untested assumption.", "The facts were never checked.", "The speaker was not listening.", "The conclusion was too long."),
            gram=[("grant", "grants", "granting", "granted"), ("still", "yet", "already", "ever"), ("because", "although", "unless", "whereas"),
                  ("is not", "are not", "do not", "has not")],
            tf=("Mina agrees with every conclusion once the facts are agreed.", False, "Agreement on the facts is not agreement on what follows."),
            dict="Agreement on the facts is not agreement on the conclusion.",
        ),
        "c2-culture": dict(
            tip="A cultural reference can fail when the room does not share the story. “The joke lands only if the room shares the story.” “The story it points at may be missing.” “Explaining it spends the laugh.” “She would rather be understood than impressive.” Translate the point into plain speech.",
            read=("Understood.", "Impressive.", "Funny.", "Clever."),
            listen=("The laugh.", "The time.", "The story.", "The point."),
            gram=[("only if", "only that", "if only", "only when if"), ("that", "who", "what", "whom"), ("spends", "spend", "to spend", "is spend"),
                  ("rather", "better", "more", "prefer")],
            tf=("Mina keeps a local saying even when the room does not know it.", False, "She decides the room does not hold it and translates the point into plain speech."),
            dict="Explaining the joke spends the laugh.",
        ),
        "c2-multi": dict(
            tip="Hold a problem across fields without blurring them. “One sees a constraint, one a risk, and one a year of tradeoffs.” A fix for only one view will fail. “Averaging them is not a synthesis.” Use “only” to mark the limit and “will” to state the result.",
            read=("Average them into a soft sentence.", "List them in a table.", "Ask each expert to leave.", "Choose the cheapest view."),
            listen=("It will fail in practice.", "It will be cheap to run.", "It will please every field.", "It will be finished quickly."),
            gram=[("and", "nor", "than", "yet"), ("only", "just only", "onlys", "alone"), ("will", "would to", "did", "is"), ("is not", "are not", "does not", "has not")],
            tf=("Mina averages the three views into one soft sentence.", False, "She refuses to average the views and keeps the constraint, the human risk and the budget year visible at once."),
            dict="Averaging the views is not a synthesis.",
        ),
    }
