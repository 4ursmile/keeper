import yaml
class Config:
    def __init__(self):
        with open("./ai_config.yaml") as f:
            self.cfg = yaml.load(f, Loader=yaml.FullLoader)
    def get(self, key):
        return self.config[key]