/*
 * %CopyrightBegin%
 *
 * Copyright Ericsson AB 2010-2020. All Rights Reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 * %CopyrightEnd%
 */

#ifndef E_HMAC_H__
#define E_HMAC_H__ 1

#ifndef HAS_EVP_PKEY_CTX

#include "common.h"

int init_hmac_ctx(ErlNifEnv *env);

ERL_NIF_TERM hmac_init_nif(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[]);
ERL_NIF_TERM hmac_update_nif(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[]);
ERL_NIF_TERM hmac_final_nif(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[]);

int hmac_low_level(ErlNifEnv* env, const EVP_MD *md,
                   ErlNifBinary key_bin, ErlNifBinary text,
                   ErlNifBinary *ret_bin, int *ret_bin_alloc, ERL_NIF_TERM *return_term);
#endif

#endif /* E_HMAC_H__ */
