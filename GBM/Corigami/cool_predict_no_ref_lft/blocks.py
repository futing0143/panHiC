import torch
import torch.nn as nn
import numpy as np
import copy


class ConvBlock(nn.Module):
    def __init__(self, size, stride=2, hidden_in=64, hidden=64):
        super(ConvBlock, self).__init__()
        pad_len = int(size / 2)
        self.scale = nn.Sequential(
            nn.Conv1d(hidden_in, hidden, size, stride, pad_len),
            nn.BatchNorm1d(hidden),
            nn.ReLU(),
        )
        self.res = nn.Sequential(
            nn.Conv1d(hidden, hidden, size, padding=pad_len),
            nn.BatchNorm1d(hidden),
            nn.ReLU(),
            nn.Conv1d(hidden, hidden, size, padding=pad_len),
            nn.BatchNorm1d(hidden),
        )
        self.relu = nn.ReLU()

    def forward(self, x):
        scaled = self.scale(x)
        identity = scaled
        res_out = self.res(scaled)
        out = self.relu(res_out + identity)
        return out


class Encoder(nn.Module):
    def __init__(self, in_channel, output_size=256, filter_size=5, num_blocks=12):
        super(Encoder, self).__init__()
        self.filter_size = filter_size
        self.conv_start = nn.Sequential(
            nn.Conv1d(in_channel, 32, 3, 2, 1),
            nn.BatchNorm1d(32),
            nn.ReLU(),
        )
        sizes_1 = [1,1,1,1,1,1,1,1,1,1,1,1]

        hiddens = [32, 32, 32, 32, 64, 64, 128, 128, 128, 128, 256, 256]
        hidden_ins = [32, 32, 32, 32, 32, 64, 64, 128, 128, 128, 128, 256]
        self.res_blocks1 = self.get_res_blocks(num_blocks, sizes_1, hidden_ins, hiddens)


        self.conv_end = nn.Conv1d(256, output_size, 1)

    def forward(self, x):
        x = self.conv_start(x)
        x = self.res_blocks(x)
        out = self.conv_end(x)
        return out

    def get_res_blocks(self, n,sizes, his, hs):
        blocks = []
        for i,filter_size, h, hi in zip(range(n), sizes, hs, his):
            blocks.append(ConvBlock(filter_size, hidden_in=hi, hidden=h))
        res_blocks = nn.Sequential(*blocks)
        return res_blocks


class EncoderSplit(Encoder):
    def __init__(self, num_epi, output_size=256, filter_size=5, num_blocks=12):
        super(Encoder, self).__init__()
        self.filter_size = filter_size
        self.conv_start_seq = nn.Sequential(
            nn.Conv1d(7, 16, 3, 2, 1),
            nn.BatchNorm1d(16),
            nn.ReLU(),
        )
        self.conv_start_epi = nn.Sequential(
            nn.Conv1d(7, 16, 3, 2, 1),
            nn.BatchNorm1d(16),
            nn.ReLU(),
        )

        sizes_1 = [1,1,1,1,1,1,1,1,1,1,1,1]
        sizes_3 = [3,3,3,3,3,3,3,3,3,3,3,3]
        sizes_7 = [7,7,7,7,7,7,7,7,7,7,7,7]
        sizes_15 = [15,15,15,15,15,15,15,15,15,15,15,15]
        sizes_31 = [31,31,31,31,31,31,31,31,31,31,31,31]
        sizes_63 = [63,63,63,63,63,63,63,63,63,63,63,63]
        sizes_127 = [127,127,127,127,127,127,127,127,127,127,127,127]
        sizes_255 = [255,255,255,255,255,255,255,255,255,255,255,255]


        hiddens = [32, 32, 32, 32, 64, 64, 128, 128, 128, 128, 256, 256]
        hidden_ins = [32, 32, 32, 32, 32, 64, 64, 128, 128, 128, 128, 256]
        hiddens_half = (np.array(hiddens) / 2).astype(int)
        hidden_ins_half = (np.array(hidden_ins) / 2).astype(int)
        self.res_blocks_1 = self.get_res_blocks(num_blocks,sizes_1, hidden_ins_half, hiddens_half)
        self.res_blocks_3 = self.get_res_blocks(num_blocks,sizes_3, hidden_ins_half, hiddens_half)
        self.res_blocks_7 = self.get_res_blocks(num_blocks,sizes_7, hidden_ins_half, hiddens_half)
        self.res_blocks_15 = self.get_res_blocks(num_blocks,sizes_15, hidden_ins_half, hiddens_half)
        #self.res_blocks_31 = self.get_res_blocks(num_blocks,sizes_31, hidden_ins_half, hiddens_half)
        #self.res_blocks_63 = self.get_res_blocks(num_blocks,sizes_63, hidden_ins_half, hiddens_half)
        #self.res_blocks_127 = self.get_res_blocks(num_blocks,sizes_127, hidden_ins_half, hiddens_half)
        #self.res_blocks_255 = self.get_res_blocks(num_blocks,sizes_255, hidden_ins_half, hiddens_half)


        self.conv_end = nn.Conv1d(128*4, output_size, 1)

    def forward(self, x):
        #seq = x[:, :5, :]
        #epi = x[:, 5:, :]
        # print("EncoderSplit", x.shape)
        #[2, 7, 2097152]
        # print("after self.conv_start_seq(x)", self.conv_start_seq(x).shape)
        Fea1 = self.res_blocks_1(self.conv_start_seq(x)) #[2, 16, 1048576] -> [2, 128, 256]
        # print('Fea1', Fea1.shape)
        Fea3 = self.res_blocks_3(self.conv_start_epi(x))
        Fea7 = self.res_blocks_7(self.conv_start_epi(x))
        Fea15 = self.res_blocks_15(self.conv_start_epi(x))
        #Fea31 = self.res_blocks_31(self.conv_start_epi(x))
        #Fea63 = self.res_blocks_63(self.conv_start_epi(x))
        #Fea127 = self.res_blocks_127(self.conv_start_epi(x))
        #Fea255 = self.res_blocks_255(self.conv_start_epi(x))


        #x = torch.cat([Fea1, Fea3, Fea7, Fea15, Fea31], dim=1)

        x = torch.cat([Fea1, Fea3, Fea7, Fea15], dim=1)
        #[2, 512, 256]
        # print(x.shape)
        Fea1 = Fea1.cpu()
        Fea3 = Fea3.cpu()
        Fea7 = Fea7.cpu()
        Fea15 = Fea15.cpu()
        #Fea31 = Fea31.cpu()
        #Fea63 = Fea63.cpu()
        #Fea127 = Fea127.cpu()
        #Fea255 = Fea255.cpu()

        del Fea1, Fea3, Fea7, Fea15#, Fea31, Fea63#, Fea127, Fea255
        torch.cuda.empty_cache()

        x = self.conv_end(x)
        # print(x.shape)
        # [2, 256, 256]
        return x


class ResBlockDilated(nn.Module):
    def __init__(self, size, hidden=64, stride=1, dil=2):
        super(ResBlockDilated, self).__init__()
        pad_len = dil
        self.res = nn.Sequential(
            nn.Conv2d(hidden, hidden, size, padding=pad_len,
                      dilation=dil),
            nn.BatchNorm2d(hidden),
            nn.ReLU(),
            nn.Conv2d(hidden, hidden, size, padding=pad_len,
                      dilation=dil),
            nn.BatchNorm2d(hidden),
        )
        self.relu = nn.ReLU()

    def forward(self, x):
        identity = x
        res_out = self.res(x)
        out = self.relu(res_out + identity)
        return out


class Decoder(nn.Module):
    def __init__(self, in_channel, hidden=256, filter_size=3, num_blocks=5):
        super(Decoder, self).__init__()
        self.filter_size = filter_size

        self.conv_start = nn.Sequential(
            nn.Conv2d(in_channel, hidden, 3, 1, 1),
            nn.BatchNorm2d(hidden),
            nn.ReLU(),
        )
        self.res_blocks = self.get_res_blocks(num_blocks, hidden)
        self.conv_end = nn.Conv2d(hidden, 1, 1)

    def forward(self, x):
        # print('1',x.shape)
        # [2, 512, 256, 256]
        x = self.conv_start(x)
        # print('2',x.shape)
        # [2, 256, 256, 256]
        x = self.res_blocks(x)
        # print('3',x.shape)
        # [2, 256, 256, 256]
        out = self.conv_end(x) # 收束通道
        # print('4',x.shape)
        # [2, 1, 256, 256]
        return out

    def get_res_blocks(self, n, hidden):
        blocks = []
        for i in range(n):
            dilation = 2 ** (i + 1)
            blocks.append(ResBlockDilated(self.filter_size, hidden=hidden, dil=dilation))
        res_blocks = nn.Sequential(*blocks)
        return res_blocks


class TransformerLayer(torch.nn.TransformerEncoderLayer):
    # Pre-LN structure

    def forward(self, src, src_mask=None, src_key_padding_mask=None):
        # MHA section
        src_norm = self.norm1(src)
        src_side, attn_weights = self.self_attn(src_norm, src_norm, src_norm,
                                                attn_mask=src_mask,
                                                key_padding_mask=src_key_padding_mask)
        src = src + self.dropout1(src_side)

        # MLP section
        src_norm = self.norm2(src)
        src_side = self.linear2(self.dropout(self.activation(self.linear1(src_norm))))
        src = src + self.dropout2(src_side)
        return src, attn_weights


class TransformerEncoder(torch.nn.TransformerEncoder):

    def __init__(self, encoder_layer, num_layers, norm=None, record_attn=False):
        super(TransformerEncoder, self).__init__(encoder_layer, num_layers)
        self.layers = self._get_clones(encoder_layer, num_layers)
        self.num_layers = num_layers
        self.norm = norm
        self.record_attn = record_attn

    def forward(self, src, mask=None, src_key_padding_mask=None):
        r"""Pass the input through the encoder layers in turn.

        Args:
            src: the sequence to the encoder (required).
            mask: the mask for the src sequence (optional).
            src_key_padding_mask: the mask for the src keys per batch (optional).

        Shape:
            see the docs in Transformer class.
        """
        output = src

        attn_weight_list = []

        for mod in self.layers:
            output, attn_weights = mod(output, src_mask=mask, src_key_padding_mask=src_key_padding_mask)
            attn_weight_list.append(attn_weights.unsqueeze(0).detach())
        if self.norm is not None:
            output = self.norm(output)

        if self.record_attn:
            return output, torch.cat(attn_weight_list)
        else:
            return output

    def _get_clones(self, module, N):
        return torch.nn.modules.ModuleList([copy.deepcopy(module) for i in range(N)])


class PositionalEncoding(nn.Module):

    def __init__(self, hidden, dropout=0.1, max_len=256):
        super().__init__()
        self.dropout = nn.Dropout(p=dropout)
        position = torch.arange(max_len).unsqueeze(1)
        div_term = torch.exp(torch.arange(0, hidden, 2) * (-np.log(10000.0) / hidden))
        pe = torch.zeros(max_len, 1, hidden)
        pe[:, 0, 0::2] = torch.sin(position * div_term)
        pe[:, 0, 1::2] = torch.cos(position * div_term)
        self.register_buffer('pe', pe)

    def forward(self, x):
        """
        Args:
            x: Tensor, shape [seq_len, batch_size, embedding_dim]
        """
        x = x + self.pe[:x.size(0)]
        return self.dropout(x)


class AttnModule(nn.Module):
    def __init__(self, hidden=256, layers=8, record_attn=False, inpu_dim=256):
        super(AttnModule, self).__init__()
        self.record_attn = record_attn
        self.pos_encoder = PositionalEncoding(hidden, dropout=0.1)
        encoder_layers = TransformerLayer(hidden,
                                          nhead=8,
                                          dropout=0.1,
                                          dim_feedforward=512,
                                          batch_first=True)
        self.module = TransformerEncoder(encoder_layers,
                                         layers,
                                         record_attn=record_attn)

    def forward(self, x):
        x = self.pos_encoder(x)
        output = self.module(x)
        return output

    def inference(self, x):
        return self.module(x)
