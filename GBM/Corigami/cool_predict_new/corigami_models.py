import torch
import torch.nn as nn

import blocks as blocks

class ConvModel(nn.Module):
    def __init__(self, num_genomic_features, mid_hidden = 256):
        super(ConvModel, self).__init__()
        print('Initializing ConvModel')

        self.encoder = blocks.EncoderSplit(num_genomic_features, output_size = mid_hidden, num_blocks = 12) 
        self.decoder = blocks.Decoder(mid_hidden * 2)

    def forward(self, x):
        '''
        Input feature:
        batch_size, length * res, feature_dim
        '''
        x = self.move_feature_forward(x).float() #[2, 2097152, 7] -> [2, 7, 2097152]
        x = self.encoder(x) #[2, 7, 2097152] -> [2, 256, 256]
        x = self.diagonalize(x)
        x = self.decoder(x).squeeze(1)
        return x

    def move_feature_forward(self, x):
        '''
        input dim:
        bs, img_len, feat
        to: 
        bs, feat, img_len
        '''
        return x.transpose(1, 2).contiguous()

    def diagonalize(self, x):
        x_i = x.unsqueeze(2).repeat(1, 1, 256, 1)
        x_j = x.unsqueeze(3).repeat(1, 1, 1, 256)
        input_map = torch.cat([x_i, x_j], dim = 1)
        return input_map

class ConvTransModel(ConvModel):
    
    def __init__(self, num_genomic_features, mid_hidden = 256, record_attn = False):
        super(ConvTransModel, self).__init__(num_genomic_features)
        print('Initializing ConvTransModel')
        self.encoder = blocks.EncoderSplit(num_genomic_features, output_size = mid_hidden, num_blocks = 12)
        self.attn = blocks.AttnModule(hidden = mid_hidden, record_attn = record_attn)
        self.decoder = blocks.Decoder(mid_hidden * 2)
        self.record_attn = record_attn
    
    def forward(self, x):
        '''
        Input feature:
        batch_size, length * res, feature_dim
        '''
        # print('1', x.shape)
        #[2, 2097152, 7]
        x = self.move_feature_forward(x).float()
        # print('2', x.shape)
        #[2, 7, 2097152]
        x = self.encoder(x)
        # print('3', x.shape)
        #[2, 256, 256]
        x = self.move_feature_forward(x)
        #[2, 256, 256]
        if self.record_attn:
            x, attn_weights = self.attn(x)
        else:
            x = self.attn(x)
        # [2, 256, 256]
        x = self.move_feature_forward(x)
        # [2, 256, 256]
        x = self.diagonalize(x)
        # [2, 512, 256, 256]
        x = self.decoder(x)
        # [2, 1 ,256, 256]
        x = x.squeeze(1)
        # [2, 256, 256]
        # print(self.decoder(x).shape) #-> [2, 1, 256, 256]
        # [2, 256, 256]
        if self.record_attn:
            return x, attn_weights
        else:
            return x


