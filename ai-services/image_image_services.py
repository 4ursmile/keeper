import torch
from PIL import Image
import open_clip


class ImageSamer:
    def __init__(self, threshold=0.6):
        self.device = "cuda" if torch.cuda.is_available() else "cpu"
        self.model , _, self.preprocess = open_clip.create_model_and_transforms('ViT-B-32', pretrained='laion2b_s34b_b79k')
        self.model.eval()
        self.threshold = threshold
    def cosine_similarity(self, x1, x2):
        return torch.nn.functional.cosine_similarity(x1, x2).item()
    def get_score(self, img1, img2) -> float:
    
        img1 = self.preprocess(img1).unsqueeze(0)
        img2 = self.preprocess(img2).unsqueeze(0)
        with torch.no_grad(), torch.cuda.amp.autocast():
            imgf1 = self.model.encode_image(img1).float()
            imgf2 = self.model.encode_image(img2).float()
        score = self.cosine_similarity(imgf1, imgf2)
        if score < self.threshold:
            return {
                "result": "no",
                "message": "It seems you took the wrong places. Let's try again."
            }
        return {
            "result": "yes",
            "message": "Great, the images are the same. Let's start, Good Luck!."
        }
        