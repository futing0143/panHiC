import pytorch_lightning as pl
import pytorch_lightning.callbacks as callbacks
from corigami_models import ConvTransModel
class LightningModel(pl.LightningModule):
    def __init__(self):
        super().__init__()
        self.model = ConvTransModel(2)
    def forward(self, x):
        return self.model(x)