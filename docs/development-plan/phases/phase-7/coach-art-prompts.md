# Coach art prompts (for ChatGPT image generation)

Five coaches have no art. Animals are my suggestion; change any of them before you generate. For each coach: paste the **style block** and then the **coach line** into one message. Attach `CoachGrammarian` and `CoachBusiness` (in `application/SpeechCoachAI/Resources/Assets.xcassets/`) as style references.

## Style block (use for every image)

> Layered cut-paper collage illustration, like the two attached images. One anthropomorphic animal character with visible paper texture, torn and cut edges, soft shadows between layers, and fine colored-pencil detail on fur or feathers. Muted palette: deep teal, mustard ochre, navy blue, warm tan and cream. A few abstract paper shapes and leaves behind the character. Plain warm cream paper background (about #F4EFE4) with no border, no frame and no text, letters or logos. Friendly, smart and calm expression. The character is centered with generous empty space around it. Landscape, 5:4, at least 1152 × 928 px.

## Coach lines

| Coach (track) | Suggested animal | Coach line |
|---|---|---|
| Debater & Argument | Wolf | A grey wolf in a navy waistcoat stands at a small wooden lectern with a stack of index cards, one paw raised as if making a point; a small brass timer sits on the lectern. |
| Persuasion & Negotiation | Penguin | A penguin in a teal bow tie sits at a small round table with two cups of tea and a folded paper agreement, offering a handshake with one flipper. |
| Creative Writing | Cat | A tabby cat in a mustard cardigan sits at a desk with a fountain pen and an open notebook; paper cranes and a small typewriter sit beside it. |
| Storytelling | Hedgehog | A hedgehog in a little scarf sits on a tree stump holding an open storybook, with a glowing paper lantern beside it and paper stars above. |
| Advertising & Copywriting | Magpie | A magpie with teal-sheen feathers perches beside a small easel showing a blank poster, holding a pencil in its beak, with a tiny paper megaphone at its feet. |

## Handing the images over

Save each image as a JPG named for its coach: `debater.jpg`, `negotiator.jpg`, `creative-writer.jpg`, `storyteller.jpg`, `copywriter.jpg`. Put them in `docs/development-plan/phases/phase-7/art/` and tell Claude. Claude adds them to the asset catalog and removes the SF Symbol placeholders. If an image comes back with text or a frame, ask ChatGPT for "the same image with no text and no border".
